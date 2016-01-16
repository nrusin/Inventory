#!/usr/bin/perl -w
use strict;
use warnings;
 

# Use the TRUE and FALSE constants exported by the Glib module.
use Glib qw/TRUE FALSE/;
use Gtk2 '-init';

# This is a callback function. We simply say hello to the world, and destroy
# the window object in order to close the program.
sub hello
{
	my ($widget, $data) = @_;

	print "hello\n";

}

sub delete_event
{
	# If you return FALSE in the "delete_event" signal handler,
	# GTK will emit the "destroy" signal. Returning TRUE means
	# you don't want the window to be destroyed.
	# This is useful for popping up 'are you sure you want to quit?'
	# type dialogs.
	print "delete event occurred\n";

	# Change TRUE to FALSE and the main window will be destroyed with
	# a "delete_event".
	return FALSE;
}

sub close_event {
    print "close\n";

}


sub build_menu {

    my $menu_item_file = Gtk2::MenuItem->new('_File');
    my $menu_item_view = Gtk2::MenuItem->new('_View');
    my $menu_item_options = Gtk2::MenuItem->new('_Options');

    my $menu_item_help = Gtk2::MenuItem->new('_Help');
#    $menu_item_help->set_sensitive(FALSE);
    $menu_item_help->set_right_justified(TRUE);


    my $menu_file = Gtk2::Menu->new();
    my $menu_options = Gtk2::Menu->new();
    my $menu_edit = Gtk2::Menu->new();
    my $menu_view = Gtk2::Menu->new();
    my $menu_help = Gtk2::Menu->new();

    my $menu_item_configure = Gtk2::MenuItem->new('_Configure');

    $menu_options->append($menu_item_configure);
    $menu_item_options->set_submenu($menu_options);



    ## File
        my $menu_item_open = Gtk2::MenuItem->new('_Open');
        my $menu_item_close = Gtk2::MenuItem->new('_Close');

        $menu_file->append($menu_item_open);
        $menu_file->append(Gtk2::SeparatorMenuItem->new());

        $menu_file->append($menu_item_close);
        $menu_item_file->set_submenu($menu_file);

        $menu_item_close->signal_connect('activate' => sub { close_event();});


    ## Edit   

    #--------
    #add a tearoff item
        # $menu_edit->append(Gtk2::TearoffMenuItem->new);
    
        
        my $menu_item_cut = Gtk2::ImageMenuItem->new_from_stock ('gtk-cut', undef);
        #connet to the activate signal to catch when this item is selected
        $menu_item_cut->signal_connect('activate' => sub { print "selected the cut menu\n"});
        $menu_edit->append($menu_item_cut);
    
        #_________
        #add a separator
        $menu_edit->append(Gtk2::SeparatorMenuItem->new());
    
        #_________
        #add a check menu item	
        my $menu_item_toggle = Gtk2::CheckMenuItem->new('_Toggle Menu Item');
        #connect to the toggled signal to catch the active state
        $menu_item_toggle->signal_connect('toggled' => \&toggle,"Toggle Menu Item");
        $menu_edit->append($menu_item_toggle);
    
        #_________
        #add a separator
        $menu_edit->append(Gtk2::SeparatorMenuItem->new());
    
        #_________
        #add radio menu items	
        my $menu_radio_one = Gtk2::RadioMenuItem->new(undef,'Radio one');
        #connect to the toggled signal to catch the changes
        $menu_radio_one->signal_connect('toggled' => \&toggle,"Radio one");
        my $group = $menu_radio_one->get_group;
        $menu_edit->append($menu_radio_one);
    
        my $menu_radio_two = Gtk2::RadioMenuItem->new($group, 'Radio two');
        #connect to the toggled signal to catch the changes
        $menu_radio_two->signal_connect('toggled' => \&toggle,"Radio two");
        $menu_edit->append($menu_radio_two);
    
        #_________
        #add a separator
        $menu_edit->append(Gtk2::SeparatorMenuItem->new());
    
        #_________
        #add an Image Menu Item using an external image
        my $menu_item_image = Gtk2::ImageMenuItem->new ('Image Menu Item');
        my $img = Gtk2::Image->new_from_file('./pix/1.png');
        $menu_item_image->signal_connect('activate' => sub { print "selected the Image Menu Item\n"});
        #connet to the activate signal to catch when this item is selected
        $menu_item_image->set_image($img);
    
        $menu_edit->append($menu_item_image);
        #====================================
    
    
        my $menu_item_edit= Gtk2::MenuItem->new('_Edit');
       
        $menu_item_edit->set_submenu ($menu_edit);
    
    # View
        my $menu_view_vendors = Gtk2::MenuItem->new('_View Vendors');
        my $menu_view_departments = Gtk2::MenuItem->new('_View Departments');
        my $menu_view_stockrooms = Gtk2::MenuItem->new('_View Stockrooms');

        $menu_view->append($menu_view_vendors);
        $menu_view->append($menu_view_departments);
        $menu_view->append($menu_view_stockrooms);

        $menu_item_view->set_submenu($menu_view);
    # Help
        my $menu_item_about = Gtk2::MenuItem->new('_About');
    
        $menu_help->append($menu_item_about);

        $menu_item_help->set_submenu($menu_help);

    my $menu_bar = Gtk2::MenuBar->new;
    $menu_bar->append($menu_item_file);
    $menu_bar->append($menu_item_edit);
    $menu_bar->append($menu_item_view);
    $menu_bar->append($menu_item_options);
    $menu_bar->append($menu_item_help);	







    
    return $menu_bar;

}




# create a new window
my $window = Gtk2::Window->new('toplevel');

# When the window is given the "delete_event" signal (this is given
# by the window manager, usually by the "close" option, or on the
# titlebar), we ask it to call the delete_event () functio
# as defined above. No data is passed to the callback function.
$window->signal_connect(delete_event => \&delete_event);

# Here we connect the "destroy" event to a signal handler.
# This event occurs when we call Gtk2::Widget::destroy on the window,
# or if we return FALSE in the "delete_event" callback. Perl supports
# anonymous subs, so we can use one of them for one line callbacks.
$window->signal_connect(destroy => sub { Gtk2->main_quit; });

# Sets the border width of the window.
$window->set_border_width(10);







my $box1 = Gtk2::VBox->new(FALSE, 0);

my $menu_bar = build_menu();


$box1->pack_start($menu_bar, FALSE, FALSE, 0);

$menu_bar->show();

$window->add($box1);


my $button_products       = Gtk2::Button->new("Products");
my $button_invoices       = Gtk2::Button->new("Invoices");
my $button_transfers      = Gtk2::Button->new("Transfers");
my $button_replenishments = Gtk2::Button->new("Replenishments");
my $button_orders         = Gtk2::Button->new("Orders");
my $button_pick_orders    = Gtk2::Button->new("Pick Orders");


$box1->pack_start($button_products, TRUE, FALSE, 0);
$box1->pack_start($button_invoices, TRUE, FALSE, 0);
$box1->pack_start($button_transfers, TRUE, FALSE, 0);
$box1->pack_start($button_replenishments, TRUE, FALSE, 0);
$box1->pack_start($button_orders, TRUE, FALSE, 0);
$box1->pack_start($button_pick_orders, TRUE, FALSE, 0);

$button_products->signal_connect(clicked => \&hello);


# The final step is to display this newly created widget.
$button_products->show;
$button_invoices->show;
$button_transfers->show;
$button_replenishments->show;
$button_orders->show;
$button_pick_orders->show;

$box1->show_all();

# and the window
$window->show;

# All GTK applications must have a call to the main() method. Control ends here
# and waits for an event to occur (like a key press or a mouse event).
Gtk2->main;

0;
