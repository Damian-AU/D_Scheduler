### By Damian Brakel ###
set plugin_name "D_Scheduler"

dui add variable saver 0 0 -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill #aaa -textvariable {[::plugins::D_Scheduler::timer_check]}

namespace eval ::plugins::${plugin_name} {
    
    # These are shown in the plugin selection page
    variable author "Damian"
    variable contact "via Diaspora"
    variable description ""
    variable version 1.0.0
    variable min_de1app_version {1.36.5}

    proc build_ui {} {
        if {$::settings(scheduler_enable) == 1} {
            set ::settings(scheduler_enable) 0
            ::save_settings
        }
        # Unique name per page
        set page_name "D_scheduler"
        dui page add $page_name
        set font_colour #333
        set click_colour #888
        set ::plugins::D_Scheduler::hours 10
        set ::plugins::D_Scheduler::minutes_tens 0
        set ::plugins::D_Scheduler::minutes_units 0
        set ::plugins::D_Scheduler::minutes 0
        set ::plugins::D_Scheduler::pm am
        set picker_x 560
        set picker_y -100
        set day_x 240
        set day_y 40
        set button_height 100
        set button_label_colour #333
        set button_outline_width 2
        set button_outline_colour #ccc

        foreach day {Mon Tue Wed Thu Fri Sat Sun} {
            if { ! [info exists ::D_scheduler_times($day)] } {
                set ::D_scheduler_times($day) {}
            }
        }

        # Background image and "Done" button
        dui add canvas_item rect $page_name 0 0 2560 1600 -fill "#d7d9e6" -width 0
        dui add canvas_item rect $page_name 10 188 2552 1424 -fill "#ededfa" -width 0
        dui add canvas_item rect $page_name 210 412 2354 1192 -fill #fff -width 3 -outline #e9e9ed
        dui add canvas_item line $page_name 12 186 2552 186 -fill "#c7c9d5" -width 3
        dui add canvas_item line $page_name 2552 186 2552 1424 -fill "#c7c9d5" -width 3
        dui add dbutton $page_name 1034 1250 \
            -bwidth 492 -bheight 120 \
            -shape round -fill #c1c5e4 \
            -label [translate "Done"] -label_font Helv_10_bold -label_fill #fAfBff -label_pos {0.5 0.5} \
            -command {if {$::settings(skin) == "DSx"} {restore_DSx_live_graph}; set_next_page off off; dui page load off; ::plugins::D_Scheduler::save_schedule}

        # Testing shortcuts
        #dui add dbutton D_scheduler 0 1210 -bwidth 120 -bheight 200 -command {dui page load extensions}
        #dui add dbutton extensions 0 1210 -bwidth 120 -bheight 200 -command {dui page load D_scheduler}

        # Headline
        dui add dtext $page_name 1280 300 -text [translate "D_Scheduler"] -font Helv_20_bold -fill $font_colour -anchor "center" -justify "center"

        dui add dbutton $page_name [expr $picker_x + 1124] [expr $picker_y + 600] \
            -bwidth 650 -bheight 400 -tags picker_outline \
            -shape outline -width $button_outline_width -outline $button_outline_colour

        #hours
        dui add variable $page_name [expr $picker_x + 1200] [expr $picker_y + 800] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -textvariable {$::plugins::D_Scheduler::hours}
        dui add dbutton $page_name [expr $picker_x + 1124] [expr $picker_y + 600] \
            -bwidth 150 -bheight 200 -tags hour_up \
            -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::D_Scheduler::hours < 12} {
                    set ::plugins::D_Scheduler::hours [expr $::plugins::D_Scheduler::hours + 1]
                } else {
                    set ::plugins::D_Scheduler::hours 1
                }
            }

        dui add dbutton $page_name [expr $picker_x + 1124] [expr $picker_y + 800] \
            -bwidth 150 -bheight 200 -tags hour_down \
            -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::D_Scheduler::hours > 1} {
                    set ::plugins::D_Scheduler::hours [expr $::plugins::D_Scheduler::hours - 1]
                } else {
                    set ::plugins::D_Scheduler::hours 12
                }
            }

        dui add dtext $page_name [expr $picker_x + 1300] [expr $picker_y +  784] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -text ":"

        #minutes_tens
        dui add variable $page_name [expr $picker_x + 1400] [expr $picker_y + 800] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -textvariable {$::plugins::D_Scheduler::minutes_tens}
        dui add dbutton $page_name [expr $picker_x + 1324] [expr $picker_y +  600] \
            -bwidth 150 -bheight 200 -tags minutes_ten_up \
            -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::D_Scheduler::minutes < 49} {
                    set ::plugins::D_Scheduler::minutes [expr $::plugins::D_Scheduler::minutes + 10]
                } else {
                    set ::plugins::D_Scheduler::minutes [expr $::plugins::D_Scheduler::minutes - 50]
                }
                ::plugins::D_Scheduler::minutes_digits
            }

        dui add dbutton $page_name [expr $picker_x + 1324] [expr $picker_y +  800] \
            -bwidth 150 -bheight 200 -tags minutes_ten_down \
            -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::D_Scheduler::minutes > 9} {
                    set ::plugins::D_Scheduler::minutes [expr $::plugins::D_Scheduler::minutes - 10]
                } else {
                    set ::plugins::D_Scheduler::minutes [expr $::plugins::D_Scheduler::minutes + 50]
                }
                ::plugins::D_Scheduler::minutes_digits
            }

        #minutes
        dui add variable $page_name [expr $picker_x + 1550] [expr $picker_y +  800] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -textvariable {$::plugins::D_Scheduler::minutes_units}
        dui add dbutton $page_name [expr $picker_x + 1474] [expr $picker_y +  600] \
            -bwidth 150 -bheight 200 -tags minutes_up \
            -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::D_Scheduler::minutes < 59} {
                    set ::plugins::D_Scheduler::minutes [expr $::plugins::D_Scheduler::minutes + 1]
                } else {
                    set ::plugins::D_Scheduler::minutes 0
                }
                ::plugins::D_Scheduler::minutes_digits
            }

        dui add dbutton $page_name [expr $picker_x + 1474] [expr $picker_y +  800] \
            -bwidth 150 -bheight 200 -tags minutes_down \
            -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::plugins::D_Scheduler::minutes > 0} {
                    set ::plugins::D_Scheduler::minutes [expr $::plugins::D_Scheduler::minutes - 1]
                } else {
                    set ::plugins::D_Scheduler::minutes 59
                }
                ::plugins::D_Scheduler::minutes_digits
            }

        #pm
        dui add variable $page_name [expr $picker_x + 1700] [expr $picker_y +  800] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 30] -fill $font_colour -textvariable {$::plugins::D_Scheduler::pm}
        dui add dbutton $page_name [expr $picker_x + 1624] [expr $picker_y +  600] \
            -bwidth 150 -bheight 200 -tags pm_up \
            -label \uf106 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {if {$::plugins::D_Scheduler::pm == "am"} {set ::plugins::D_Scheduler::pm pm} else {set ::plugins::D_Scheduler::pm am}}
        dui add dbutton $page_name [expr $picker_x + 1624] [expr $picker_y + 800] \
            -bwidth 150 -bheight 200 -tags pm_down \
            -label \uf107 -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {if {$::plugins::D_Scheduler::pm == "am"} {set ::plugins::D_Scheduler::pm pm} else {set ::plugins::D_Scheduler::pm am}}

        #day buttons
        dui add variable $page_name [expr $day_x + 90] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::D_scheduler_times(Mon)}
        dui add variable $page_name [expr $day_x + 290] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::D_scheduler_times(Tue)}
        dui add variable $page_name [expr $day_x + 490] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::D_scheduler_times(Wed)}
        dui add variable $page_name [expr $day_x + 690] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::D_scheduler_times(Thu)}
        dui add variable $page_name [expr $day_x + 890] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::D_scheduler_times(Fri)}
        dui add variable $page_name [expr $day_x + 1090] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::D_scheduler_times(Sat)}
        dui add variable $page_name [expr $day_x + 1290] [expr $day_y + 600] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill "#444444" -textvariable {$::D_scheduler_times(Sun)}
        dui add variable $page_name [expr $day_x + 700] [expr $day_y + 770] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 26] -fill "#00dd00" -textvariable {$::plugins::D_Scheduler::message}
        dui add dtext $page_name [expr $day_x + 700] [expr $day_y + 394] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 13] -fill "#777" -text [translate "Tap a day below to add the current TIME DIAL setting to the day's list of wake up times"]
        dui add dtext $page_name [expr $picker_x + 1460] [expr $picker_y + 550] -justify center -anchor n -font [dui font get "Font Awesome 5 Pro-Regular-400" 15] -fill $font_colour -text [translate "TIME DIAL"]

        dui add dbutton $page_name [expr $day_x + 0] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Mon \
            -label Mon -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::set_time Mon}
        dui add dbutton $page_name [expr $day_x + 200] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Tue \
            -label Tue -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::set_time Tue}
        dui add dbutton $page_name [expr $day_x + 400] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Wed \
            -label Wed -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::set_time Wed}
        dui add dbutton $page_name [expr $day_x + 600] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Thu \
            -label Thu -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::set_time Thu}
        dui add dbutton $page_name [expr $day_x + 800] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Fri \
            -label Fri -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::set_time Fri}
        dui add dbutton $page_name [expr $day_x + 1000] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Sat \
            -label Sat -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::set_time Sat}
        dui add dbutton $page_name [expr $day_x + 1200] [expr $day_y + 440] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags set_Sun \
            -label Sun -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::set_time Sun}

        #clear days
        dui add dbutton $page_name [expr $day_x + 0] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Mon \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::clear_time Mon}
        dui add dbutton $page_name [expr $day_x + 200] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Tue \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::clear_time Tue}
        dui add dbutton $page_name [expr $day_x + 400] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Wed \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::clear_time Wed}
        dui add dbutton $page_name [expr $day_x + 600] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Thu \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::clear_time Thu}
        dui add dbutton $page_name [expr $day_x + 800] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Fri \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::clear_time Fri}
        dui add dbutton $page_name [expr $day_x + 1000] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Sat \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::clear_time Sat}
        dui add dbutton $page_name [expr $day_x + 1200] [expr $day_y + 1000] \
            -bwidth 190 -bheight $button_height -shape outline -width $button_outline_width -outline $button_outline_colour -tags clear_Sun \
            -label Clear -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 18] -label_fill $button_label_colour -label_pos {0.5 0.5} \
            -command {::plugins::D_Scheduler::clear_time Sun}


        dui add dtext $page_name [expr $picker_x + 1454] [expr $picker_y + 1126] -justify center -anchor center -font [dui font get "Font Awesome 5 Pro-Regular-400" 14] -fill $font_colour -text [translate "return to sleep after"]

        dui add dbutton $page_name [expr $picker_x + 1174] [expr $picker_y + 1100] \
            -bwidth 560 -bheight 100 \
            -labelvariable {[minutes_text $::settings(screen_saver_delay)]} -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 16] -label_fill $font_colour -label_pos {0.5 0.7} \
            -shape outline -width $button_outline_width -outline $button_outline_colour

        dui add dbutton $page_name [expr $picker_x + 1174] [expr $picker_y +  1100] \
            -bwidth 150 -bheight 100 \
            -label "-" -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 22] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::settings(screen_saver_delay) > 10} {
                    set ::settings(screen_saver_delay) [expr $::settings(screen_saver_delay) - 1]
                } else {
                    set ::plugins::D_Scheduler::minutes 10
                }
                save_settings;
            }

        dui add dbutton $page_name [expr $picker_x + 1584] [expr $picker_y +  1100] \
            -bwidth 150 -bheight 100 \
            -label "+" -label_font [dui font get "Font Awesome 5 Pro-Regular-400" 22] -label_fill $click_colour -label_pos {0.5 0.5} \
            -command {
                if {$::settings(screen_saver_delay) < 120} {
                    set ::settings(screen_saver_delay) [expr $::settings(screen_saver_delay) + 1]
                } else {
                    set ::settings(screen_saver_delay) 120
                }
                save_settings;
            }

        return $page_name
    }

    proc check_versions {} {
        if { [package vcompare [package version de1app] $::plugins::D_Scheduler::min_de1app_version] < 0 } {
            variable description "        * * *  WARNING  * * *\rDPx Scheduler is not compatable with \rApp Version [package version de1app]\rPlease update to version $::plugins::D_Scheduler::min_de1app_version or newer"
        }
    }
    check_versions

    proc timer_check {} {
        after 100 {::plugins::D_Scheduler::scan_times}
        return ""
    }

    proc remove_zero { x } {
        scan $x %d n
        return $n
    }

    proc scan_times {} {
        set ct [clock seconds]
        set day [clock format $ct -format {%a}]
        set mins [expr {([remove_zero [clock format $ct -format {%H}]] * 60 ) + [remove_zero [clock format $ct -format {%M}]]}]
        if {[info exist ::D_scheduler_minutes($day)] == 1} {
            foreach time $::D_scheduler_minutes($day) {
                if {$time == $mins} {
                    start_idle
                }
            }
        }
    }

    proc clear_time { day } {
        set ::D_scheduler_minutes($day) ""
        set ::D_scheduler_times($day) ""
    }
    proc checkArr {name} {
        upvar $name arr
        if {![info exists arr(key1)]} {
            return 0
        } else {
            return 1
        }
    }

    proc set_time { day } {
        if {$::plugins::D_Scheduler::pm == "pm" && $::plugins::D_Scheduler::hours != 12} {
            set sh [expr $::plugins::D_Scheduler::hours + 12]
        } else {
            set sh $::plugins::D_Scheduler::hours
        }
        if {$::plugins::D_Scheduler::pm == "am" && $sh == 12} {
            set sh [expr $::plugins::D_Scheduler::hours - 12]
        }
        set m [expr ($sh * 60) + $::plugins::D_Scheduler::minutes]
        set s [expr $m * 60]
        set z [clock format [clock seconds] -format {%z}]
        set sep " "
        if {[info exists ::D_scheduler_minutes($day)] == 1} {
            if {[lsearch -exact $::D_scheduler_minutes($day) $m] >= 0} {
                set ::plugins::D_Scheduler::message "That time already exists"
                after 1200 {set ::plugins::D_Scheduler::message ""}
            } else {
                append ::D_scheduler_times($day) [clock format $s -format {%I:%M%P} -gmt $z] \r
                append ::D_scheduler_minutes($day) $sep$m$sep
            }
        } else {
            append ::D_scheduler_times($day) [clock format $s -format {%I:%M%P} -gmt $z] \r
            append ::D_scheduler_minutes($day) $sep$m$sep
        }
    }

    proc load_sched {} {
        set fn "[plugin_directory]/D_Scheduler/schedule.tbd"
        array set ::D_scheduler_minutes [encoding convertfrom utf-8 [read_binary_file $fn]]
        foreach day {Mon Tue Wed Thu Fri Sat Sun} {
            if {[info exists ::D_scheduler_minutes($day)] == 1} {
                foreach m $::D_scheduler_minutes($day) {
                    set s [expr $m * 60]
                    set z [clock format [clock seconds] -format {%z}]
                    append ::D_scheduler_times($day) [clock format $s -format {%I:%M%P} -gmt $z] \r
                }
            }
        }
    }

    if {[file exist "[plugin_directory]/D_Scheduler/schedule.tbd"]} {
        ::plugins::D_Scheduler::load_sched
    }

    proc save_schedule {} {
        msg "saving DPx Schedule"
        set fn "[plugin_directory]/D_Scheduler/schedule.tbd"
        upvar ::D_scheduler_minutes item
        set D_shed {}
        foreach k [lsort -dictionary [array names item]] {
            set v $item($k)
            append D_shed [subst {[list $k] [list $v]\n}]
        }
        write_file $fn $D_shed
    }

    proc minutes_digits {} {
        if {$::plugins::D_Scheduler::minutes >= 50 && $::plugins::D_Scheduler::minutes < 60} {
            set a 5
        } elseif {$::plugins::D_Scheduler::minutes >= 40 && $::plugins::D_Scheduler::minutes < 50} {
            set a 4
        } elseif {$::plugins::D_Scheduler::minutes >= 30 && $::plugins::D_Scheduler::minutes < 40} {
            set a 3
        } elseif {$::plugins::D_Scheduler::minutes >= 20 && $::plugins::D_Scheduler::minutes < 30} {
            set a 2
        } elseif {$::plugins::D_Scheduler::minutes >= 10 && $::plugins::D_Scheduler::minutes < 20} {
            set a 1
        } else {
            set a 0
        }
        set ::plugins::D_Scheduler::minutes_tens $a
        set ::plugins::D_Scheduler::minutes_units [round_to_integer [expr {$::plugins::D_Scheduler::minutes - ($a * 10)}]]
    }

    if {$::settings(skin) == "DSx"} {
        # dui add dbutton off 600 0 -bwidth 1200 -bheight 200 -command {page_to_show_when_off D_scheduler}
    }

    proc main {} {
        plugins gui D_Scheduler [build_ui]
    }
}
