# Start with:   /usr/lib/YaST2/bin/y2start ./dasdfmt_progress_01.rb qt
#
# Notice that this demo will run until 42%, then it will stop.
# Use the "Abort" button or the window manager [x] button to close.

require "yast"
require "yast/i18n"

Yast.import "UI"
Yast.import "Label"

module Yast
  # Class for displaying progress while formatting one or several DASDs.
  class DasdFmtProgress
    include Yast::I18n
    include Yast::UIShortcuts
    include Yast::Logger

    TIMEOUT_MILLISEC = 10
    MAX_PROGRESS = 42

    def initialize(total_cyl)
      textdomain "s390"
      @total_cyl = total_cyl
      @cyl = 0
      @progress = 0 # percent
    end

    def run
      UI.OpenDialog(dialog_content)
      demo_event_loop # Runs until 42%
      UI.CloseDialog
    end

    def dialog_content
      MinSize(
        60, 12,
        MarginBox(1, 0.45, dialog_vbox)
      )
    end

    def dialog_vbox
      VBox(
          Heading(_("Formatting DASDs")),
          VSpacing(1),
          VStretch(),
          ProgressBar(Id(:progress_bar), _("Total Progress"), 100, 0),
          VStretch(),
          VSpacing(1),
          PushButton(Id(:abort), _("Abort"))
        )
    end

    def demo_event_loop
      loop do
        id = UI.TimeoutUserInput(TIMEOUT_MILLISEC)
        case id
        when :timeout
          update_cyl(@cyl + 1 ) if @progress < MAX_PROGRESS

        when :abort, :cancel # :cancel is WM_CLOSE
          # Break the loop
          log.info("Closing")
          break
        end
      end
    end

    def update_progress(percent)
      @progress = percent
      UI.ChangeWidget(Id(:progress_bar), :Value, @progress)
    end

    def update_cyl(cyl)
      @cyl = cyl
      update_progress(100 * @cyl / @total_cyl)
    end
  end
end

Yast::DasdFmtProgress.new(420).run
