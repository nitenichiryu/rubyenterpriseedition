#
# tk/scrollbar.rb : treat scrollbar widget
#
require 'tk'

class TkScrollbar<TkWindow
  TkCommandNames = ['scrollbar'.freeze].freeze
  WidgetClassName = 'Scrollbar'.freeze
  WidgetClassNames[WidgetClassName] = self

  def create_self(keys)
    @assigned = []
    @scroll_proc = proc{|*args| 
      if self.orient == 'horizontal'
	@assigned.each{|w| w.xview(*args)}
      else # 'vertical'
	@assigned.each{|w| w.yview(*args)}
      end
    }

    if keys and keys != None
      tk_call_without_enc('scrollbar', @path, *hash_kv(keys, true))
    else
      tk_call_without_enc('scrollbar', @path)
    end
  end
  private :create_self

  def assign(*wins)
    begin
      self.command(@scroll_proc) if self.cget('command').cmd != @scroll_proc
    rescue Exception
      self.command(@scroll_proc)
    end
    orient = self.orient
    wins.each{|w|
      @assigned << w unless @assigned.index(w)
      if orient == 'horizontal'
	w.xscrollcommand proc{|first, last| self.set(first, last)}
      else # 'vertical'
	w.yscrollcommand proc{|first, last| self.set(first, last)}
      end
    }
    self
  end

  def assigned_list
    begin
      return @assigned.dup if self.cget('command').cmd == @scroll_proc
    rescue Exception
    end
    fail RuntimeError, "not depend on the assigned_list"
  end

  #def delta(deltax=None, deltay=None)
  def delta(deltax, deltay)
    number(tk_send_without_enc('delta', deltax, deltay))
  end

  #def fraction(x=None, y=None)
  def fraction(x, y)
    number(tk_send_without_enc('fraction', x, y))
  end

  def identify(x, y)
    tk_send_without_enc('identify', x, y)
  end

  def get
    #ary1 = tk_send('get').split
    #ary2 = []
    #for i in ary1
    #  ary2.push number(i)
    #end
    #ary2
    list(tk_send_without_enc('get'))
  end

  def set(first, last)
    tk_send_without_enc('set', first, last)
    self
  end

  def activate(element=None)
    tk_send_without_enc('activate', element)
  end
end

class TkXScrollbar<TkScrollbar
  def create_self(keys)
    keys = {} unless keys
    keys['orient'] = 'horizontal'
    super(keys)
  end
  private :create_self
end

class TkYScrollbar<TkScrollbar
  def create_self(keys)
    keys = {} unless keys
    keys['orient'] = 'vertical'
    super(keys)
  end
  private :create_self
end