#
#		tk/canvas.rb - Tk canvas classes
#			$Date$
#			by Yukihiro Matsumoto <matz@caelum.co.jp>
#			$Date$
#			by Hidetoshi Nagai <nagai@ai.kyutech.ac.jp>
#
require 'tk'
require 'tk/canvastag'
require 'tk/itemfont'
require 'tk/scrollable'

module TkTreatCItemFont
  include TkTreatItemFont

  ItemCMD = ['itemconfigure'.freeze, TkComm::None].freeze
  def __conf_cmd(idx)
    ItemCMD[idx]
  end

  def __item_pathname(tagOrId)
    if tagOrId.kind_of?(TkcItem) || tagOrId.kind_of?(TkcTag)
      self.path + ';' + tagOrId.id.to_s
    else
      self.path + ';' + tagOrId.to_s
    end
  end

  private :__conf_cmd, :__item_pathname
end

class TkCanvas<TkWindow
  include TkTreatCItemFont
  include Scrollable

  TkCommandNames = ['canvas'.freeze].freeze
  WidgetClassName = 'Canvas'.freeze
  WidgetClassNames[WidgetClassName] = self

  def __destroy_hook__
    TkcItem::CItemID_TBL.delete(@path)
  end

  def create_self(keys)
    if keys and keys != None
      tk_call_without_enc('canvas', @path, *hash_kv(keys, true))
    else
      tk_call_without_enc('canvas', @path)
    end
  end
  private :create_self

  def tagid(tag)
    if tag.kind_of?(TkcItem) || tag.kind_of?(TkcTag)
      tag.id
    else
      tag
    end
  end
  private :tagid


  def create(type, *args)
    # create a canvas item without creating a TkcItem object
    if type.kind_of?(TkcItem)
      fail ArgumentError, 'TkcItem class expected for 1st argument'
    end
    type.create(@path, *args)
  end


  def addtag(tag, mode, *args)
    tk_send_without_enc('addtag', tagid(tag), mode, *args)
    self
  end
  def addtag_above(tagOrId, target)
    addtag(tagOrId, 'above', tagid(target))
  end
  def addtag_all(tagOrId)
    addtag(tagOrId, 'all')
  end
  def addtag_below(tagOrId, target)
    addtag(tagOrId, 'below', tagid(target))
  end
  def addtag_closest(tagOrId, x, y, halo=None, start=None)
    addtag(tagOrId, 'closest', x, y, halo, start)
  end
  def addtag_enclosed(tagOrId, x1, y1, x2, y2)
    addtag(tagOrId, 'enclosed', x1, y1, x2, y2)
  end
  def addtag_overlapping(tagOrId, x1, y1, x2, y2)
    addtag(tagOrId, 'overlapping', x1, y1, x2, y2)
  end
  def addtag_withtag(tagOrId, tag)
    addtag(tagOrId, 'withtag', tagid(tag))
  end

  def bbox(tagOrId, *tags)
    list(tk_send_without_enc('bbox', tagid(tagOrId), 
			     *tags.collect{|t| tagid(t)}))
  end

  def itembind(tag, context, cmd=Proc.new, args=nil)
    _bind([path, "bind", tagid(tag)], context, cmd, args)
    self
  end

  def itembind_append(tag, context, cmd=Proc.new, args=nil)
    _bind_append([path, "bind", tagid(tag)], context, cmd, args)
    self
  end

  def itembind_remove(tag, context)
    _bind_remove([path, "bind", tagid(tag)], context)
    self
  end

  def itembindinfo(tag, context=nil)
    _bindinfo([path, "bind", tagid(tag)], context)
  end

  def canvasx(screen_x, *args)
    #tk_tcl2ruby(tk_send_without_enc('canvasx', screen_x, *args))
    number(tk_send_without_enc('canvasx', screen_x, *args))
  end
  def canvasy(screen_y, *args)
    #tk_tcl2ruby(tk_send_without_enc('canvasy', screen_y, *args))
    number(tk_send_without_enc('canvasy', screen_y, *args))
  end

  def coords(tag, *args)
    if args == []
      tk_split_list(tk_send_without_enc('coords', tagid(tag)))
    else
      tk_send_without_enc('coords', tagid(tag), *(args.flatten))
    end
  end

  def dchars(tag, first, last=None)
    tk_send_without_enc('dchars', tagid(tag), 
			_get_eval_enc_str(first), _get_eval_enc_str(last))
    self
  end

  def delete(*args)
    if TkcItem::CItemID_TBL[self.path]
      find('withtag', *args).each{|item| 
	TkcItem::CItemID_TBL[self.path].delete(item.id)
      }
    end
    tk_send_without_enc('delete', *args.collect{|t| tagid(t)})
    self
  end
  alias remove delete

  def dtag(tag, tag_to_del=None)
    tk_send_without_enc('dtag', tagid(tag), tag_to_del)
    self
  end

  def find(mode, *args)
    list(tk_send_without_enc('find', mode, *args)).collect!{|id| 
      TkcItem.id2obj(self, id)
    }
  end
  def find_above(target)
    find('above', tagid(target))
  end
  def find_all
    find('all')
  end
  def find_below(target)
    find('below', tagid(target))
  end
  def find_closest(x, y, halo=None, start=None)
    find('closest', x, y, halo, start)
  end
  def find_enclosed(x1, y1, x2, y2)
    find('enclosed', x1, y1, x2, y2)
  end
  def find_overlapping(x1, y1, x2, y2)
    find('overlapping', x1, y1, x2, y2)
  end
  def find_withtag(tag)
    find('withtag', tag)
  end

  def itemfocus(tagOrId=nil)
    if tagOrId
      tk_send_without_enc('focus', tagid(tagOrId))
      self
    else
      ret = tk_send_without_enc('focus')
      if ret == ""
	nil
      else
	TkcItem.id2obj(self, ret)
      end
    end
  end

  def gettags(tagOrId)
    list(tk_send_without_enc('gettags', tagid(tagOrId))).collect{|tag|
      TkcTag.id2obj(self, tag)
    }
  end

  def icursor(tagOrId, index)
    tk_send_without_enc('icursor', tagid(tagOrId), index)
    self
  end

  def index(tagOrId, index)
    number(tk_send_without_enc('index', tagid(tagOrId), index))
  end

  def insert(tagOrId, index, string)
    tk_send_without_enc('insert', tagid(tagOrId), index, 
			_get_eval_enc_str(string))
    self
  end

  def itemcget(tagOrId, option)
    case option.to_s
    when 'dash', 'activedash', 'disableddash'
      conf = tk_send_without_enc('itemcget', tagid(tagOrId), "-#{option}")
      if conf =~ /^[0-9]/
	list(conf)
      else
	conf
      end
    when 'text', 'label', 'show', 'data', 'file', 'maskdata', 'maskfile'
      _fromUTF8(tk_send_without_enc('itemcget', tagid(tagOrId), "-#{option}"))
    when 'font', 'kanjifont'
      #fnt = tk_tcl2ruby(tk_send('itemcget', tagid(tagOrId), "-#{option}"))
      fnt = tk_tcl2ruby(_fromUTF8(tk_send_with_enc('itemcget', tagid(tagOrId), '-font')))
      unless fnt.kind_of?(TkFont)
	fnt = tagfontobj(tagid(tagOrId), fnt)
      end
      if option.to_s == 'kanjifont' && JAPANIZED_TK && TK_VERSION =~ /^4\.*/
	# obsolete; just for compatibility
	fnt.kanji_font
      else
	fnt
      end
    else
      tk_tcl2ruby(_fromUTF8(tk_send_without_enc('itemcget', tagid(tagOrId), 
						"-#{option}")))
    end
  end

  def itemconfigure(tagOrId, key, value=None)
    if key.kind_of? Hash
      key = _symbolkey2str(key)
      if ( key['font'] || key['kanjifont'] \
	  || key['latinfont'] || key['asciifont'] )
	tagfont_configure(tagid(tagOrId), key.dup)
      else
	_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId), 
				      *hash_kv(key, true)))
      end

    else
      if ( key == 'font' || key == :font || 
           key == 'kanjifont' || key == :kanjifont || 
	   key == 'latinfont' || key == :latinfont || 
           key == 'asciifont' || key == :asciifont )
	if value == None
	  tagfontobj(tagid(tagOrId))
	else
	  tagfont_configure(tagid(tagOrId), {key=>value})
	end
      else
	_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId), 
				      "-#{key}", _get_eval_enc_str(value)))
      end
    end
    self
  end
#  def itemconfigure(tagOrId, key, value=None)
#    if key.kind_of? Hash
#      tk_send 'itemconfigure', tagid(tagOrId), *hash_kv(key)
#    else
#      tk_send 'itemconfigure', tagid(tagOrId), "-#{key}", value
#    end
#  end
#  def itemconfigure(tagOrId, keys)
#    tk_send 'itemconfigure', tagid(tagOrId), *hash_kv(keys)
#  end

  def itemconfiginfo(tagOrId, key=nil)
    if TkComm::GET_CONFIGINFO_AS_ARRAY
      if key
	case key.to_s
	when 'dash', 'activedash', 'disableddash'
	  conf = tk_split_simplelist(tk_send_without_enc('itemconfigure', tagid(tagOrId), "-#{key}"))
	  if conf[3] && conf[3] =~ /^[0-9]/
	    conf[3] = list(conf[3])
	  end
	  if conf[4] && conf[4] =~ /^[0-9]/
	    conf[4] = list(conf[4])
	  end
	when 'text', 'label', 'show', 'data', 'file', 'maskdata', 'maskfile'
	  conf = tk_split_simplelist(_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId), "-#{key}")))
	when 'font', 'kanjifont'
	  conf = tk_split_simplelist(_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId),"-#{key}")))
	  conf[4] = tagfont_configinfo(tagid(tagOrId), conf[4])
	else
	  conf = tk_split_list(_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId), "-#{key}")))
	end
	conf[0] = conf[0][1..-1]
	conf
      else
	ret = tk_split_simplelist(_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId)))).collect{|conflist|
	  conf = tk_split_simplelist(conflist)
	  conf[0] = conf[0][1..-1]
	  case conf[0]
	  when 'text', 'label', 'show', 'data', 'file', 'maskdata', 'maskfile'
	  when 'dash', 'activedash', 'disableddash'
	    if conf[3] && conf[3] =~ /^[0-9]/
	      conf[3] = list(conf[3])
	    end
	    if conf[4] && conf[4] =~ /^[0-9]/
	      conf[4] = list(conf[4])
	    end
	  else
	    if conf[3]
	      if conf[3].index('{')
		conf[3] = tk_split_list(conf[3]) 
	      else
		conf[3] = tk_tcl2ruby(conf[3]) 
	      end
	    end
	    if conf[4]
	      if conf[4].index('{')
		conf[4] = tk_split_list(conf[4]) 
	      else
		conf[4] = tk_tcl2ruby(conf[4]) 
	      end
	    end
	  end
	  conf[1] = conf[1][1..-1] if conf.size == 2 # alias info
	  conf
	}
	fontconf = ret.assoc('font')
	if fontconf
	  ret.delete_if{|item| item[0] == 'font' || item[0] == 'kanjifont'}
	  fontconf[4] = tagfont_configinfo(tagid(tagOrId), fontconf[4])
	  ret.push(fontconf)
	else
	  ret
	end
      end
    else # ! TkComm::GET_CONFIGINFO_AS_ARRAY
      if key
	case key.to_s
	when 'dash', 'activedash', 'disableddash'
	  conf = tk_split_simplelist(tk_send_without_enc('itemconfigure', 
							 tagid(tagOrId), 
							 "-#{key}"))
	  if conf[3] && conf[3] =~ /^[0-9]/
	    conf[3] = list(conf[3])
	  end
	  if conf[4] && conf[4] =~ /^[0-9]/
	    conf[4] = list(conf[4])
	  end
	when 'text', 'label', 'show', 'data', 'file', 'maskdata', 'maskfile'
	  conf = tk_split_simplelist(_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId), "-#{key}")))
	when 'font', 'kanjifont'
	  conf = tk_split_simplelist(_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId),"-#{key}")))
	  conf[4] = tagfont_configinfo(tagid(tagOrId), conf[4])
	else
	  conf = tk_split_list(_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId), "-#{key}")))
	end
	key = conf.shift[1..-1]
	{ key => conf }
      else
	ret = {}
	tk_split_simplelist(_fromUTF8(tk_send_without_enc('itemconfigure', tagid(tagOrId)))).each{|conflist|
	  conf = tk_split_simplelist(conflist)
	  key = conf.shift[1..-1]
	  case key
	  when 'text', 'label', 'show', 'data', 'file', 'maskdata', 'maskfile'
	  when 'dash', 'activedash', 'disableddash'
	    if conf[2] && conf[2] =~ /^[0-9]/
	      conf[2] = list(conf[2])
	    end
	    if conf[3] && conf[3] =~ /^[0-9]/
	      conf[3] = list(conf[3])
	    end
	  else
	    if conf[2]
	      if conf[2].index('{')
		conf[2] = tk_split_list(conf[2]) 
	      else
		conf[2] = tk_tcl2ruby(conf[2]) 
	      end
	    end
	    if conf[3]
	      if conf[3].index('{')
		conf[3] = tk_split_list(conf[3]) 
	      else
		conf[3] = tk_tcl2ruby(conf[3]) 
	      end
	    end
	  end
	  if conf.size == 1
	    ret[key] = conf[0][1..-1]  # alias info
	  else
	    ret[key] = conf
	  end
	}
	fontconf = ret['font']
	if fontconf
	  ret.delete('font')
	  ret.delete('kanjifont')
	  fontconf[3] = tagfont_configinfo(tagid(tagOrId), fontconf[3])
	  ret['font'] = fontconf
	end
	ret
      end
    end
  end

  def current_itemconfiginfo(tagOrId, key=nil)
    if TkComm::GET_CONFIGINFO_AS_ARRAY
      if key
	conf = itemconfiginfo(tagOrId, key)
	{conf[0] => conf[4]}
      else
	ret = {}
	itemconfiginfo(tagOrId).each{|conf|
	  ret[conf[0]] = conf[4] if conf.size > 2
	}
	ret
      end
    else # ! TkComm::GET_CONFIGINFO_AS_ARRAY
      ret = {}
      itemconfiginfo(tagOrId, key).each{|k, conf|
	ret[k] = conf[-1] if conf.kind_of?(Array)
      }
      ret
    end
  end

  def lower(tag, below=nil)
    if below
      tk_send_without_enc('lower', tagid(tag), tagid(below))
    else
      tk_send_without_enc('lower', tagid(tag))
    end
    self
  end

  def move(tag, x, y)
    tk_send_without_enc('move', tagid(tag), x, y)
    self
  end

  def postscript(keys)
    tk_send("postscript", *hash_kv(keys))
  end

  def raise(tag, above=nil)
    if above
      tk_send_without_enc('raise', tagid(tag), tagid(above))
    else
      tk_send_without_enc('raise', tagid(tag))
    end
    self
  end

  def scale(tag, x, y, xs, ys)
    tk_send_without_enc('scale', tagid(tag), x, y, xs, ys)
    self
  end

  def scan_mark(x, y)
    tk_send_without_enc('scan', 'mark', x, y)
    self
  end
  def scan_dragto(x, y)
    tk_send_without_enc('scan', 'dragto', x, y)
    self
  end

  def select(mode, *args)
    r = tk_send_without_enc('select', mode, *args)
    (mode == 'item')? TkcItem.id2obj(self, r): self
  end
  def select_adjust(tagOrId, index)
    select('adjust', tagid(tagOrId), index)
  end
  def select_clear
    select('clear')
  end
  def select_from(tagOrId, index)
    select('from', tagid(tagOrId), index)
  end
  def select_item
    select('item')
  end
  def select_to(tagOrId, index)
    select('to', tagid(tagOrId), index)
  end

  def itemtype(tag)
    TkcItem.type2class(tk_send('type', tagid(tag)))
  end
end

class TkcItem<TkObject
  extend Tk
  include TkcTagAccess

  CItemTypeToClass = {}
  CItemID_TBL = TkCore::INTERP.create_table

  TkCore::INTERP.init_ip_env{ CItemID_TBL.clear }

  def TkcItem.type2class(type)
    CItemTypeToClass[type]
  end

  def TkcItem.id2obj(canvas, id)
    cpath = canvas.path
    return id unless CItemID_TBL[cpath]
    CItemID_TBL[cpath][id]? CItemID_TBL[cpath][id]: id
  end

  ########################################
  def self.create(canvas, *args)
    fail RuntimeError, "TkcItem is an abstract class"
  end
  ########################################

  def initialize(parent, *args)
    unless parent.kind_of?(TkCanvas)
      fail ArguemntError, "expect TkCanvas for 1st argument"
    end
    @parent = @c = parent
    @path = parent.path
    fontkeys = {}
    if args.size == 1 && args[0].kind_of?(Hash)
      args[0] = _symbolkey2str(args[0])
      coords = args[0].delete('coords')
      unless coords.kind_of?(Array)
        fail "coords parameter must be given by an Array"
      end
      args[0,0] = coords.flatten
    end
    if args[-1].kind_of? Hash
      keys = _symbolkey2str(args.pop)
      ['font', 'kanjifont', 'latinfont', 'asciifont'].each{|key|
	fontkeys[key] = keys.delete(key) if keys.key?(key)
      }
      args.concat(hash_kv(keys))
    end
    @id = create_self(*args).to_i ;# 'canvas item id' is integer number
    CItemID_TBL[@path] = {} unless CItemID_TBL[@path]
    CItemID_TBL[@path][@id] = self
    configure(fontkeys) unless fontkeys.empty?

######## old version
#    if args[-1].kind_of? Hash
#      keys = args.pop
#    end
#    @id = create_self(*args).to_i ;# 'canvas item id' is integer number
#    CItemID_TBL[@path] = {} unless CItemID_TBL[@path]
#    CItemID_TBL[@path][@id] = self
#    if keys
#      # tk_call @path, 'itemconfigure', @id, *hash_kv(keys)
#      configure(keys) if keys
#    end
########
  end
  def create_self(*args)
    self.class.create(@path, *args)
  end
  private :create_self

  def id
    @id
  end

  def delete
    @c.delete @id
    CItemID_TBL[@path].delete(@id) if CItemID_TBL[@path]
    self
  end
  alias remove  delete
  alias destroy delete
end

class TkcArc<TkcItem
  CItemTypeToClass['arc'] = self
  def self.create(path, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop
      args.concat(hash_kv(keys))
    end
    tk_call_without_enc(path, 'create', 'arc', *args)
  end
end

class TkcBitmap<TkcItem
  CItemTypeToClass['bitmap'] = self
  def self.create(path, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop
      args.concat(hash_kv(keys))
    end
    tk_call_without_enc(path, 'create', 'bitmap', *args)
  end
end

class TkcImage<TkcItem
  CItemTypeToClass['image'] = self
  def self.create(path, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop
      args.concat(hash_kv(keys))
    end
    tk_call_without_enc(path, 'create', 'image', *args)
  end
end

class TkcLine<TkcItem
  CItemTypeToClass['line'] = self
  def self.create(path, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop
      args.concat(hash_kv(keys))
    end
    tk_call_without_enc(path, 'create', 'line', *args)
  end
end

class TkcOval<TkcItem
  CItemTypeToClass['oval'] = self
  def self.create(path, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop
      args.concat(hash_kv(keys))
    end
    tk_call_without_enc(path, 'create', 'oval', *args)
  end
end

class TkcPolygon<TkcItem
  CItemTypeToClass['polygon'] = self
  def self.create(path, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop
      args.concat(hash_kv(keys))
    end
    tk_call_without_enc(path, 'create', 'polygon', *args)
  end
end

class TkcRectangle<TkcItem
  CItemTypeToClass['rectangle'] = self
  def self.create(path, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop
      args.concat(hash_kv(keys))
    end
    tk_call_without_enc(path, 'create', 'rectangle', *args)
  end
end

class TkcText<TkcItem
  CItemTypeToClass['text'] = self
  def self.create(path, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop
      args.concat(hash_kv(keys))
    end
    #tk_call_without_enc(path, 'create', 'text', 
    #			*(args.each{|arg| _get_eval_enc_str(arg)}))
    tk_call(path, 'create', 'text', *args)
  end
end

class TkcWindow<TkcItem
  CItemTypeToClass['window'] = self
  def self.create(path, *args)
    if args[-1].kind_of?(Hash)
      keys = _symbolkey2str(args.pop)
      win = keys['window']
      # keys['window'] = win.epath if win.kind_of?(TkWindow)
      keys['window'] = _epath(win) if win
      args.concat(hash_kv(keys))
    end
    tk_call_without_enc(path, 'create', 'window', *args)
  end
end