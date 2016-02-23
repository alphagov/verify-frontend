module Display
  module Rp
    class DisplayDataCorrelator
      Transactions = Struct.new(:public, :private) do
        def any?
          public.any? || private.any?
        end
      end
      Transaction = Struct.new(:name, :homepage)
      def initialize(translator)
        @translator = translator
      end

      def correlate(data)
        public = data.fetch('public')
        public_transactions = public.map do |transaction|
          name = translate_name(transaction)
          Transaction.new(name, transaction.fetch('homepage'))
        end
        private = data.fetch('private')
        private_transactions = private.map do |transaction|
          name = translate_name(transaction)
          Transaction.new(name)
        end
        Transactions.new(public_transactions, private_transactions)
      end

      def translate_name(transaction)
        simple_id = transaction.fetch('simpleId')
        @translator.translate("rps.#{simple_id}.name")
      end
    end
  end
end
