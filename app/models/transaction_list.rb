require 'taxon'
require 'display/decorated_transaction'
require 'api/response'

class TransactionList
  include Enumerable

  attr_reader :transactions

  class << self
    attr_writer :rp_display_repository
    attr_writer :rps_with_homepage
    attr_writer :rps_without_homepage

    def rps_with_homepage
      @rps_with_homepage || []
    end

    def rps_without_homepage
      @rps_without_homepage || []
    end

    def rps_supported
      rps_with_homepage + rps_without_homepage
    end

    def logger
      Rails.logger
    end

    def rp_display_repository
      RP_DISPLAY_REPOSITORY
    end

    def from(upstream_transactions)
      grouped_transactions = upstream_transactions.group_by(&:valid?)
      if grouped_transactions[false].nil?
        new(grouped_transactions[true] || [])
      else
        grouped_transactions[false].each do |invalid_transaction|
          logger.error("#{invalid_transaction.simple_id}: #{invalid_transaction.error_messages}")
        end
        new([])
      end
    end
  end


  def initialize(transactions)
    @transactions = transactions
  end

  def select_by_ids(simple_ids)
    selected = @transactions.select do |transaction|
      simple_ids.include?(transaction.simple_id)
    end
    TransactionList.new(selected)
  end

  def select_with_homepage
    select_by_ids(TransactionList.rps_with_homepage)
  end

  def select_without_homepage
    select_by_ids(TransactionList.rps_without_homepage)
  end

  def select_enabled
    select_by_ids(TransactionList.rps_supported)
  end

  def with_display_data
    rps_with_homepage = TransactionList.rps_with_homepage
    decorated_transactions = @transactions.map do |transaction|
      create_decorated_transaction(transaction, rps_with_homepage)
    end
    TransactionList.new(decorated_transactions.compact)
  end

  def each(&blk)
    @transactions.each(&blk)
  end

  def group_by_taxon
    @transactions
      .group_by(&:taxon)
      .map { |name, taxon_transactions| Taxon.new(name, taxon_transactions) }
  end

  def sort
    TransactionList.new(@transactions.sort)
  end

  def ==(other)
    @transactions == other.transactions
  end

private

  def rp_display_repository
    @rp_display_repository ||= TransactionList.rp_display_repository
  end

  def create_decorated_transaction(transaction, rps_with_homepage)
    simple_id = transaction.simple_id
    rp_display_data = rp_display_repository.get_translations(simple_id)
    Display::DecoratedTransaction.new(
      rp_display_data,
      transaction,
      rps_with_homepage.include?(simple_id)
    )
  rescue I18n::MissingTranslationData => e
    TransactionList.logger.error(e)
    nil
  end
end
