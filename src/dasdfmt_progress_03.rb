# Start with:   /usr/lib/YaST2/bin/y2start ./dasdfmt_progress_03.rb qt
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

    def initialize
      textdomain "s390"
      @cyl = 0
      @progress = 0 # percent
    end

    def run_demo(total_cyl:, max_progress: 100)
      @total_cyl = total_cyl
      @max_progress = max_progress

      open
      demo_event_loop(max_progress)
      close
    end

    def open
      UI.OpenDialog(dialog_content)
    end

    def close
      UI.CloseDialog
    end

    def dialog_content
      MarginBox(
        1, # left and right margin
        0.45, # top and bottom margin; NCurses rounds this down to 0
        VBox(
          Heading(_("Formatting DASDs")),
          MinHeight(7, tables),
          VSpacing(1),
          ProgressBar(Id(:progress_bar), _("Total Progress"), 100, 0),
          VSpacing(1),
          PushButton(Id(:abort), _("Abort"))
        )
      )
    end

    def tables
      HBox(
        MinWidth(
          35,
          VBox(
            Left(Label(_("In Progress"))),
            in_progress_table)
        ),
        HSpacing(4),
        MinWidth(
          26,
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
        Header(Right(_("Channel ID")), ("Device"), Right(_("Cyl."))),
        in_progress_items
      )
    end

    def in_progress_items
      [
        Item(Id(:dasda), "0.0.01b17", "/dev/dasda", format_cyl(@cyl, 200)),
        Item(Id(:dasdb), "0.0.01b18", "/dev/dasdb", format_cyl(@cyl, 420)),
        Item(Id(:dasdc), "0.0.01b1d", "/dev/dasdc", format_cyl(@cyl, 300)),
        Item(Id(:dasdd), "0.0.0bd71", "/dev/dasdd", format_cyl(@cyl, 200)),
        Item(Id(:dasde), "0.0.0be80", "/dev/dasde", format_cyl(@cyl, 200)),
        Item(Id(:dasdf), "0.0.0c10d", "/dev/dasdf", format_cyl(@cyl, 200)),
        Item(Id(:dasdg), "0.0.0c10e", "/dev/dasdg", format_cyl(@cyl, 200)),
        Item(Id(:dasdh), "0.0.0c42f", "/dev/dasdh", format_cyl(@cyl, 200))
      ]
    end

    def format_cyl(current_cyl, total_cyl)
      "#{current_cyl}/#{total_cyl}"
    end

    def done_table
      Table(
        Id(:done_table),
        Header(Right(_("Channel ID")), _("Device")),
        done_items
      )
    end

    def done_items
      [
        Item(Id(:dasdx), "0.0.42c7", "/dev/dasdx")
      ]
    end

    def demo_event_loop(max_progress = 100)
      loop do
        id = UI.TimeoutUserInput(TIMEOUT_MILLISEC)
        case id
        when :timeout
          update_cyl(@cyl + 1 ) if @progress < max_progress

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

Yast::DasdFmtProgress.new.run_demo(total_cyl: 420, max_progress: 42)
