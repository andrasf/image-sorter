#!/usr/bin/ruby

require 'gtk2'

ESCAPE = 65307
ENTER  = 65293

path = (ARGV.length > 0 ? ARGV.first : Dir.pwd).chomp '/'

class ImageSorter < Gtk::Window

  def initialize(path)
    @path = path
    @images = get_images
    
    abort 'No jpg or jpeg files found.' if @images.empty?
    
    puts "Path #{@path}"
    
    super
    signal_connect 'destroy' do
      Gtk.main_quit
    end
    set_default_size 600, 600
    set_window_position Gtk::Window::POS_CENTER
    init_ui
    show_all
  end

  def init_ui
    table = Gtk::Table.new 0, 0, true
    add table
    
    @imgview = Gtk::Image.new
    table.attach @imgview, 0, 4, 0, 10
        
    folders = []
    buttons = []
    
    4.times do |i|
      folders.push Gtk::Entry.new
      buttons.push Gtk::Button.new "[#{i}]"
      
      table.attach folders[i], i, i+1, 10, 11
      table.attach buttons[i], i, i+1, 11, 12
      
      folders[i].signal_connect 'key-release-event' do |w, e|
        buttons[i].grab_focus if e.keyval == ESCAPE
        buttons[i].label = "[#{i}] #{w.text}"
      end
      
      buttons[i].signal_connect 'clicked' do |w, e|
        buttons[i].grab_focus
        unless folders[i].text.empty?
          move_image folders[i].text
          get_next_image
        end
      end
      buttons[i].signal_connect 'key-press-event' do |w, e|
        if e.keyval == ENTER
          puts "Skip #{@image}"
          get_next_image
        else
          val = e.keyval-48
          buttons[val].signal_emit 'clicked' unless buttons[val].nil?
        end
      end
    end
    
    get_next_image
  end

  def get_images
    Dir.glob(["#{@path}/*.jpg", "#{@path}/*.jpeg"]).sort
  end
  
  def get_next_image
    while @mutex
      sleep 0.1
    end
    @mutex = true
    if @current and @next.nil?
      md = Gtk::MessageDialog.new self, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::INFO, Gtk::MessageDialog::BUTTONS_CLOSE, 'All done.'
      md.run
      return Gtk.main_quit
    elsif @current.nil?
      buffer_image
    end
    @image = @images.shift
    puts "Load #{@image}"
    set_title @image
    @current = @next
    @imgview.pixbuf = @current
    Thread.new do
      buffer_image
      @mutex = false
    end
  end
  
  def buffer_image
    if @images.empty?
      @next = nil
    else
      begin
        @next = Gdk::Pixbuf.new @images.first, 700, 500
      rescue
        @next = Gdk::Pixbuf.new Gdk::Pixbuf::COLORSPACE_RGB, false, 8, 700, 500
      end
    end
  end

  def move_image(to_folder)
    target = "#{@path}/#{to_folder}".chomp '/'
    Dir.mkdir target unless File.directory? target
    img = File.basename @image
    old = @image
    new = "#{target}/#{img}"
    puts "Move #{img} to #{target}"
    File.rename old, new
  end
end

Gtk.init
ImageSorter.new path
Gtk.main
