#
# tk/grid.rb : control grid geometry manager
#
require 'tk'

module TkGrid
  include Tk
  extend Tk

  TkCommandNames = ['grid'.freeze].freeze

  def anchor(master, anchor=None)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    tk_call_without_enc('grid', 'anchor', master, anchor)
  end

  def bbox(master, *args)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    args.unshift(master)
    list(tk_call_without_enc('grid', 'bbox', *args))
  end

  def configure(win, *args)
    if args[-1].kind_of?(Hash)
      opts = args.pop
    else
      opts = {}
    end
    params = []
    params.push(_epath(win))
    args.each{|win|
      case win
      when '-', 'x', '^'  # RELATIVE PLACEMENT
	params.push(win)
      else
	params.push(_epath(win))
      end
    }
    opts.each{|k, v|
      params.push("-#{k}")
      params.push((v.kind_of?(TkObject))? v.epath: v)
    }
    tk_call_without_enc("grid", 'configure', *params)
  end

  def columnconfigure(master, index, args)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    tk_call_without_enc("grid", 'columnconfigure', 
			master, index, *hash_kv(args))
  end

  def rowconfigure(master, index, args)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    tk_call_without_enc("grid", 'rowconfigure', master, index, *hash_kv(args))
  end

  def columnconfiginfo(master, index, slot=nil)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    if slot
      num_or_str(tk_call_without_enc('grid', 'columnconfigure', 
				     master, index, "-#{slot}"))
    else
      ilist = list(tk_call_without_enc('grid','columnconfigure',master,index))
      info = {}
      while key = ilist.shift
	info[key[1..-1]] = ilist.shift
      end
      info
    end
  end

  def rowconfiginfo(master, index, slot=nil)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    if slot
      num_or_str(tk_call_without_enc('grid', 'rowconfigure', 
				     master, index, "-#{slot}"))
    else
      ilist = list(tk_call_without_enc('grid', 'rowconfigure', master, index))
      info = {}
      while key = ilist.shift
	info[key[1..-1]] = ilist.shift
      end
      info
    end
  end

  def add(widget, *args)
    configure(widget, *args)
  end

  def forget(*args)
    return '' if args.size == 0
    wins = args.collect{|win|
      # (win.kind_of?(TkObject))? win.epath: win
      _epath(win)
    }
    tk_call_without_enc('grid', 'forget', *wins)
  end

  def info(slave)
    # slave = slave.epath if slave.kind_of?(TkObject)
    slave = _epath(slave)
    ilist = list(tk_call_without_enc('grid', 'info', slave))
    info = {}
    while key = ilist.shift
      info[key[1..-1]] = ilist.shift
    end
    return info
  end

  def location(master, x, y)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    list(tk_call_without_enc('grid', 'location', master, x, y))
  end

  def propagate(master, bool=None)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    if bool == None
      bool(tk_call_without_enc('grid', 'propagate', master))
    else
      tk_call_without_enc('grid', 'propagate', master, bool)
    end
  end

  def remove(*args)
    return '' if args.size == 0
    wins = args.collect{|win|
      # (win.kind_of?(TkObject))? win.epath: win
      _epath(win)
    }
    tk_call_without_enc('grid', 'remove', *wins)
  end

  def size(master)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    list(tk_call_without_enc('grid', 'size', master))
  end

  def slaves(master, args)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    list(tk_call_without_enc('grid', 'slaves', master, *hash_kv(args)))
  end

  module_function :bbox, :forget, :propagate, :info
  module_function :remove, :size, :slaves, :location
  module_function :configure, :columnconfigure, :rowconfigure
  module_function :columnconfiginfo, :rowconfiginfo
end
=begin
def TkGrid(win, *args)
  if args[-1].kind_of?(Hash)
    opts = args.pop
  else
    opts = {}
  end
  params = []
  params.push((win.kind_of?(TkObject))? win.epath: win)
  args.each{|win|
    case win
    when '-', 'x', '^'  # RELATIVE PLACEMENT
      params.push(win)
    else
      params.push((win.kind_of?(TkObject))? win.epath: win)
    end
  }
  opts.each{|k, v|
    params.push("-#{k}")
    params.push((v.kind_of?(TkObject))? v.epath: v)
  }
  tk_call_without_enc("grid", *params)
end
=end