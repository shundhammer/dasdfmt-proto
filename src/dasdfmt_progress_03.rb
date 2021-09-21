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
          38,
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
        Header(
          Right(_("Channel ID")),
          ("Device"),
          Right(_("Cyl.") + ' ' * 6) # reserve some space for more digits
        ),
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

    # Event handler (not a loop!) for the real application.
    #
    # This should be called in regular intervals during listening for progress
    # output of the dasdfmt command so the application remains responsive; in
    # particular for responding to the user hitting the "Abort" button. This is
    # not just a luxury: If a formatting operation is stuck, the user needs to
    # be able to interrupt it and start over.
    def event_handler
      id = UI.PollInput
      case id
      when :abort, :cancel # :cancel is WM_CLOSE
        # TO DO: Open a confirmation popup asking if the user really wants to
        # abort the ongoing formatting operation.
        return :cancel
      end
    end

    # Event loop just for this demo. Not needed or desired in the real
    # application.
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
      # Updating just some DASDs just for the demo
      update_cyl_cell(Id(:dasdb), cyl, 420)
      update_cyl_cell(Id(:dasdc), cyl, 300)
    end

    # Update the cylinder cell for one item of the "In Progress" table.
    #
    # @param item_id [Term] ID of the table item to update
    # @param cyl [Integer] Current cylinder of that DASD
    # @param total_cyl [Integer] Total number of cylinders of that DASD
    #
    def update_cyl_cell(item_id, cyl, total_cyl)
      return if cyl > total_cyl

      UI.ChangeWidget(Id(:in_progress_table), Cell(item_id, 2), format_cyl(cyl, total_cyl))
    end
  end
end

Yast::DasdFmtProgress.new.run_demo(total_cyl: 420, max_progress: 42)
