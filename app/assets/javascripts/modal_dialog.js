;(function (global) {
    'use strict'
  
    var GOVUK = global.GOVUK || {}
    var $ = global.jQuery
  
    GOVUK.modalDialog = {
      el: document.getElementById('js-modal-dialog'),
      $el: $('#js-modal-dialog'),
      $lastFocusedEl: null,
      $openButton: $('#openModal'),
      $closeButton: $('.modal-dialog .js-dialog-close'),
      $cancelButton: $('.modal-dialog .js-dialog-cancel'),
      dialogIsOpenClass: 'dialog-is-open',
      timers: [],
      // Timer specific markup. If these are not present, timeout and redirection are disabled
      $timer: $('#js-modal-dialog .timer'),
      $accessibleTimer: $('#js-modal-dialog .at-timer'),
      // Timer specific settings. If these are not set, timeout and redirection are disabled
      timeOutRedirectUrl: $('#js-modal-dialog').data('url-redirect'),
      expiryTime: $('#js-modal-dialog').data('utc-expiry'),
      secondsTimeOutModalVisible: $('#js-modal-dialog').data('seconds-modal-visible'),
      modalText: $('#js-modal-dialog').data('text'),
      modalExtraText: $('#js-modal-dialog').data('extra-text'),
  
      bindUIElements: function () {  
        GOVUK.modalDialog.$openButton.on('click', function (e) {
          GOVUK.modalDialog.openDialog()
          return false
        })
  
        GOVUK.modalDialog.$closeButton.on('click', function (e) {
          e.preventDefault()
          GOVUK.modalDialog.closeDialog()
        })
  
        GOVUK.modalDialog.$cancelButton.on('click', function (e) {
          _paq.push(['trackEvent', "Engagement", "Popup", "Popup signout"]);
        })
      },
      isDialogOpen: function () {
        return GOVUK.modalDialog.el['open']
      },
      isTimerSet: function () {
        return GOVUK.modalDialog.$timer.length > 0 && GOVUK.modalDialog.$accessibleTimer.length > 0 && GOVUK.modalDialog.secondsTimeOutModalVisible && GOVUK.modalDialog.timeOutRedirectUrl
      },
      openDialog: function () {
        if (!GOVUK.modalDialog.isDialogOpen()) {
          $('html, body').addClass(GOVUK.modalDialog.dialogIsOpenClass)
          GOVUK.modalDialog.saveLastFocusedEl()
          GOVUK.modalDialog.makePageContentInert()
          GOVUK.modalDialog.el.showModal()
  
          if (GOVUK.modalDialog.isTimerSet()) {
            GOVUK.modalDialog.startTimer()
          }
          _paq.push(['trackEvent', "Engagement", "Popup", "Popup open"]);
        }
      },
      closeDialog: function () {
        if (GOVUK.modalDialog.isDialogOpen()) {
          $('html, body').removeClass(GOVUK.modalDialog.dialogIsOpenClass)
          GOVUK.modalDialog.el.close()
          GOVUK.modalDialog.setFocusOnLastFocusedEl()
          GOVUK.modalDialog.removeInertFromPageContent()
          _paq.push(['trackEvent', "Engagement", "Popup", "Popup continue"]);
  
          if (GOVUK.modalDialog.isTimerSet()) {
            GOVUK.modalDialog.clearTimers()
          }
        }
      },
      saveLastFocusedEl: function () {
        GOVUK.modalDialog.$lastFocusedEl = document.activeElement
        if (!GOVUK.modalDialog.$lastFocusedEl || GOVUK.modalDialog.$lastFocusedEl === document.body) {
          GOVUK.modalDialog.$lastFocusedEl = null
        } else if (document.querySelector) {
          GOVUK.modalDialog.$lastFocusedEl = document.querySelector(':focus')
        }
      },
      // Set focus back on last focused el when modal closed
      setFocusOnLastFocusedEl: function () {
        if (GOVUK.modalDialog.$lastFocusedEl) {
          window.setTimeout(function () {
            GOVUK.modalDialog.$lastFocusedEl.focus()
          }, 0)
        }
      },
      // Set page content to inert to indicate to screenreaders it's inactive
      // NB: This will look for #content for toggling inert state
      makePageContentInert: function () {
        if (document.querySelector('#content')) {
          document.querySelector('#content').inert = true
          document.querySelector('#content').setAttribute('aria-hidden', 'true')
        }
      },
      // Make page content active when modal is not open
      // NB: This will look for #content for toggling inert state
      removeInertFromPageContent: function () {
        if (document.querySelector('#content')) {
          document.querySelector('#content').inert = false
          document.querySelector('#content').setAttribute('aria-hidden', 'false')
        }
      },
      // Starts a timer. If modal not closed before time out + 3 seconds grace period, user is redirected.
      startTimer: function () {
        GOVUK.modalDialog.clearTimers() // Clear any other modal timers that might have been running
        var $timer = GOVUK.modalDialog.$timer
        var $accessibleTimer = GOVUK.modalDialog.$accessibleTimer
        var seconds = GOVUK.modalDialog.secondsTimeOutModalVisible
        var timerRunOnce = false
        var iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
  
        if (seconds) {
          var secondsToTimeout = (new Date(GOVUK.modalDialog.expiryTime) - new Date()) / 1000
          var seconds = secondsToTimeout < seconds ? secondsToTimeout : seconds
          var minutes = parseInt(seconds / 60, 10)

          $timer.text(minutes + ' minute' + (minutes > 1 ? 's' : ''));
  
          (function runTimer () {
            var minutesLeft = parseInt(seconds / 60, 10)
            var secondsLeft = parseInt(seconds % 60, 10)
            var timerExpired = minutesLeft < 1 && secondsLeft < 1
  
            var minutesText = minutesLeft > 0 ? '<span class="tabular-numbers">' + minutesLeft + '</span> minute' + (minutesLeft > 1 ? 's' : '') + '' : ' '
            var secondsText = secondsLeft >= 1 ? ' <span class="tabular-numbers">' + secondsLeft + '</span> second' + (secondsLeft > 1 ? 's' : '') + '' : ''
            var atMinutesNumberAsText = ''
            var atSecondsNumberAsText = ''
  
            try {
              atMinutesNumberAsText = GOVUK.modalDialog.numberToWords(minutesLeft) // Attempt to convert numerics into text as iOS VoiceOver ccassionally stalled when encountering numbers
              atSecondsNumberAsText = GOVUK.modalDialog.numberToWords(secondsLeft)
            } catch (e) {
              atMinutesNumberAsText = minutesLeft
              atSecondsNumberAsText = secondsLeft
            }
  
            var atMinutesText = minutesLeft > 0 ? atMinutesNumberAsText + ' minute' + (minutesLeft > 1 ? 's' : '') + '' : ''
            var atSecondsText = secondsLeft >= 1 ? ' ' + atSecondsNumberAsText + ' second' + (secondsLeft > 1 ? 's' : '') + '' : ''
  
            // Below string will get read out by screen readers every time the timeout refreshes (every 15 secs. See below).
            // Please add additional information in the modal body content or in below extraText which will get announced to AT the first time the time out opens
            var text = GOVUK.modalDialog.modalText + ' ' + minutesText + secondsText + '. '
            var atText = GOVUK.modalDialog.modalText + atMinutesText
            if (atSecondsText) {
              if (minutesLeft > 0) {
                atText += ' and'
              }
              atText += atSecondsText + '.'
            } else {
              atText += '.'
            }
            var extraText = GOVUK.modalDialog.modalExtraText
            if (timerExpired) {
              $timer.text('You are about to be redirected.')
              $accessibleTimer.text('You are about to be redirected.')
              setTimeout(GOVUK.modalDialog.redirect, 3000)
  
            } else {
              seconds--
  
              $timer.html(text + extraText)
  
              if (minutesLeft < 1 && secondsLeft < 20) {
                $accessibleTimer.attr('aria-live', 'assertive')
              }
  
              if (!timerRunOnce) {
                // Read out the extra content only once. Don't read out on iOS VoiceOver which stalls on the longer text
  
                if (iOS) {
                  $accessibleTimer.text(atText)
                } else {
                  $accessibleTimer.text(atText + extraText)
                }
                timerRunOnce = true
              } else if (secondsLeft % 15 === 0) {
                // Update screen reader friendly content every 15 secs
                $accessibleTimer.text(atText)
              }
  
              // JS doesn't allow resetting timers globally so timers need to be retained for resetting.
              GOVUK.modalDialog.timers.push(setTimeout(runTimer, 1000))
            }
          })()
        }
      },
      // Clears modal timer
      clearTimers: function () {
        for (var i = 0; i < GOVUK.modalDialog.timers.length; i++) {
          clearTimeout(GOVUK.modalDialog.timers[i])
        }
      },
      // Close modal when ESC pressed
      escClose: function () {
        $(document).keydown(function (e) {
          if (GOVUK.modalDialog.isDialogOpen() && e.keyCode === 27) {
            GOVUK.modalDialog.closeDialog()
          }
        })
      },
      // Shows modal after a specified time
      timeTrigger: function () {
        var warningStarts = new Date(GOVUK.modalDialog.expiryTime) - (GOVUK.modalDialog.secondsTimeOutModalVisible * 1000)
        var afterSeconds = (warningStarts - new Date()) / 1000
        var milliSeconds
        var timer
  
        GOVUK.modalDialog.checkIfShouldHaveTimedOut()
  
        if (afterSeconds) {
          milliSeconds = afterSeconds * 1000
  
          window.onload = resetTimer
        }
  
        function resetTimer () {
          clearTimeout(timer)
  
          timer = setTimeout(GOVUK.modalDialog.openDialog, milliSeconds)
        }
      },
      // Do a timestamp comparison when the page regains focus to check if the user should have been timed out already
      checkIfShouldHaveTimedOut: function () {
        window.onfocus = function () {
          // Debugging tip: Above event doesn't kick in in Chrome if you have Inspector panel open and have clicked on it
          // as it is now the active element. Click on the window to make it active before moving to another tab.
          if (new Date(GOVUK.modalDialog.expiryTime) < new Date()) {
            GOVUK.modalDialog.redirect()
          }
        }
      },
      redirect: function () {
        window.location.replace(GOVUK.modalDialog.timeOutRedirectUrl)
      },
      numberToWords: function (n) {
        var string = n.toString()
        var units
        var tens
        var scales
        var start
        var end
        var chunks
        var chunksLen
        var chunk
        var ints
        var i
        var word
        var words = 'and'
  
        if (parseInt(string) === 0) {
          return 'zero'
        }
  
        /* Array of units as words */
        units = [ '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen' ]
  
        /* Array of tens as words */
        tens = [ '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety' ]
  
        /* Array of scales as words */
        scales = [ '', 'thousand', 'million', 'billion', 'trillion', 'quadrillion', 'quintillion', 'sextillion', 'septillion', 'octillion', 'nonillion', 'decillion', 'undecillion', 'duodecillion', 'tredecillion', 'quatttuor-decillion', 'quindecillion', 'sexdecillion', 'septen-decillion', 'octodecillion', 'novemdecillion', 'vigintillion', 'centillion' ]
  
        /* Split user arguemnt into 3 digit chunks from right to left */
        start = string.length
        chunks = []
        while (start > 0) {
          end = start
          chunks.push(string.slice((start = Math.max(0, start - 3)), end))
        }
  
        /* Check if function has enough scale words to be able to stringify the user argument */
        chunksLen = chunks.length
        if (chunksLen > scales.length) {
          return ''
        }
  
        /* Stringify each integer in each chunk */
        words = []
        for (i = 0; i < chunksLen; i++) {
          chunk = parseInt(chunks[i])
  
          if (chunk) {
            /* Split chunk into array of individual integers */
            ints = chunks[i].split('').reverse().map(parseFloat)
  
            /* If tens integer is 1, i.e. 10, then add 10 to units integer */
            if (ints[1] === 1) {
              ints[0] += 10
            }
  
            /* Add scale word if chunk is not zero and array item exists */
            if ((word = scales[i])) {
              words.push(word)
            }
  
            /* Add unit word if array item exists */
            if ((word = units[ints[0]])) {
              words.push(word)
            }
  
            /* Add tens word if array item exists */
            if ((word = tens[ ints[1] ])) {
              words.push(word)
            }
  
            /* Add hundreds word if array item exists */
            if ((word = units[ints[2]])) {
              words.push(word + ' hundred')
            }
          }
        }
        return words.reverse().join(' ')
      },
      init: function () {
        if (GOVUK.modalDialog.el) {
          // Native dialog is not supported by browser so use polyfill
          if (typeof HTMLDialogElement !== 'function') {
            window.dialogPolyfill.registerDialog(GOVUK.modalDialog.el)
          }
          GOVUK.modalDialog.bindUIElements()
          GOVUK.modalDialog.escClose()
  
          if (GOVUK.modalDialog.isTimerSet()) {
            GOVUK.modalDialog.timeTrigger()
          }
        }
      }
    }
    global.GOVUK = GOVUK
  })(window); // eslint-disable-line semi
  