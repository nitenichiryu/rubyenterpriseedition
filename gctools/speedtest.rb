#!/usr/bin/env ruby

def create_objects
	list = []
	2000000.times do
		list << "hello world"
	end
end

5.times do
	create_objects
	ObjectSpace.garbage_collect
end
