#!/usr/bin/perl -w
use strict;
use warnings;


use Glib qw/TRUE FALSE/;
use Gtk2 '-init';


sub quit {
    exit;

}

sub add_vendor_dialog {
    my $parent_window = shift;
    my $title = "Add Vendor";

    my $flags;

    
    my $dialog = Gtk2::Dialog->new($title, $parent_window,
				   'destroy-with-parent',
				   'gtk-cancel' => 'cancel',
				   'OK'      => 'ok');

    $dialog->set_default_response('ok');


    $dialog->signal_connect(response => sub { $_[0]->destroy });




#    my $table = Gtk2::Table->new(2, 2);

 #   $table->attach_defaults(Gtk2::Label->new('ID:'), 0, 1, 0, 1);
 #   $table->attach_defaults(Gtk2::Entry->new(), 1, 2, 0, 1);

 #   $table->attach_defaults(Gtk2::Label->new('Name:'), 0, 1, 1, 2);
 #   $table->attach_defaults(Gtk2::Entry->new(), 1, 2, 1, 2);

    my $id_hbox = Gtk2::HBox->new(FALSE, 0);

    $id_hbox->pack_start(Gtk2::Label->new('ID:'), FALSE, FALSE, 20);
    $id_hbox->pack_start(Gtk2::Entry->new(), FALSE, FALSE, 20);
    
    $dialog->vbox->add($id_hbox);

    my $name_hbox = Gtk2::HBox->new(FALSE, 0);
    
    $name_hbox->pack_start(Gtk2::Label->new('Name:'), FALSE, FALSE, 20);
    $name_hbox->pack_start(Gtk2::Entry->new(), FALSE, FALSE, 20);

    $dialog->vbox->add($name_hbox);



    my $addr_frame = Gtk2::Frame->new('Address');

    $addr_frame->set_shadow_type('etched_in');
    
    my $addr_table = Gtk2::Table->new(3, 4);
    
    $addr_table->attach_defaults(Gtk2::Label->new('Street:'), 0, 1, 0, 1);
    $addr_table->attach_defaults(Gtk2::Entry->new(), 1, 4, 0, 1);
    
    $addr_table->attach_defaults(Gtk2::Label->new('City:'), 0, 1, 1, 2);
    $addr_table->attach_defaults(Gtk2::Entry->new(), 1, 2, 1, 2);
    
    $addr_table->attach_defaults(Gtk2::Label->new('State:'), 2, 3, 1, 2);
    $addr_table->attach_defaults(Gtk2::Entry->new(), 3, 4, 1, 2);

    $addr_table->attach_defaults(Gtk2::Label->new('Zip Code:'), 0, 1, 2, 3);
    $addr_table->attach_defaults(Gtk2::Entry->new(), 1, 2, 2, 3);

    $addr_frame->add($addr_table);

    my $phone_box = Gtk2::HBox->new();

    $phone_box->add(Gtk2::Label->new('Phone #:'));
    

    $phone_box->add(Gtk2::Label->new('('));

    $phone_box->add(Gtk2::Entry->new());

    $phone_box->add(Gtk2::Label->new(')-'));

    $phone_box->add(Gtk2::Entry->new());
    $phone_box->add(Gtk2::Label->new('-'));
    $phone_box->add(Gtk2::Entry->new());



    my $notebook = Gtk2::Notebook->new();
    

    my $vbox = Gtk2::VBox->new();

   # $vbox->add($table);
    $vbox->add($addr_frame);
    $vbox->add($phone_box);
    

    $notebook->append_page($vbox, 'Main');


    my $vbox2 = Gtk2::VBox->new();
    $vbox2->add(Gtk2::Label->new("Vendor id's used for replenishment"));
    

 #   my $model = Gtk2::ListStore->new("Glib::String");


#    $model->set($model->append, 0 => 'Joe');


    $notebook->append_page($vbox2, "Details");

	    
    $dialog->vbox->add($notebook);
    
    
    $dialog->show_all;



}


my $top_window = Gtk2::Window->new('toplevel');


$top_window->set_default_size(800, 600);
$top_window->set_position('center');

$top_window->signal_connect('delete_event', \&quit);

$top_window->set_border_width(8);
$top_window->set_title('Add Vendor Example');

my $frame = Gtk2::Frame->new('Frame Title');
$frame->set_shadow_type('etched_in');

my $button = Gtk2::Button->new('Frame Contents');

$button->signal_connect('clicked', sub {Gtk2->main_quit});

#$frame->add($button);

$top_window->add($frame);

$top_window->show_all;

add_vendor_dialog($top_window);


Gtk2->main;


1;

