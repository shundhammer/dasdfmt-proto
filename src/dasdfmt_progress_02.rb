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
        60, 15,
        MarginBox(1, 0.45, dialog_vbox)
      )
    end

    def dialog_vbox
      VBox(
          Heading(_("Formatting DASDs")),
          tables,
          VSpacing(1),
          ProgressBar(Id(:progress_bar), _("Total Progress"), 100, 0),
          VSpacing(1),
          PushButton(Id(:abort), _("Abort"))
        )
    end

    def tables
      HBox(
        HWeight(
          60,
          VBox(
            Left(Label(_("In Progress"))),
            in_progress_table
          )
        ),
        HSpacing(5),
        HWeight(
          40,
          VBox(
            Left(Label(_("Done"))),
            done_table
          )
        )
      )
    end

    def in_progress_table
      Table(
        Id(:in_progress_table),
        Header(_("Device"), Right(_("Cyl.")), Right(_("Tot. Cyl"))),
        in_progress_items
      )
    end

    def in_progress_items
      [
        Item(Id(:dasda), "/dev/dasda", @cyl, 200),
        Item(Id(:dasdb), "/dev/dasdb", @cyl, 420),
        Item(Id(:dasdc), "/dev/dasdc", @cyl, 300),
        Item(Id(:dasdd), "/dev/dasdd", @cyl, 200),
        Item(Id(:dasde), "/dev/dasde", @cyl, 200),
        Item(Id(:dasdf), "/dev/dasdf", @cyl, 200),
        Item(Id(:dasdg), "/dev/dasdg", @cyl, 200),
        Item(Id(:dasdh), "/dev/dasdh", @cyl, 200)
      ]
    end

    def done_table
      Table(
        Id(:done_table),
        Header(_("Device")),
        done_items
      )
    end

    def done_items
      [
        Item(Id(:dasdx), "/dev/dasdx")
      ]
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
