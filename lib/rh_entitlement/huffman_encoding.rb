module RhEntitlement
  class HuffmanEncoding
    attr_accessor :root, :lookup, :input, :output

    def initialize(input)
      @input = input
      @root = HuffmanNodeQueue.new(input).root
    end

    def lookup
      @lookup ||= prepare_lookup
    end

    def encode(entry)
      lookup.invert[entry] || ""
    end

    def decode(code)
      lookup[code] || ""
    end

    def encode_list(list)
      code = ''
      list.each { |c| code += encode(c) }
      code
    end

    def decode_string(code)
      code = code.to_s
      string = ''
      sub_code = ''
      code.each_char do |bit|
        sub_code += bit
        unless decode(sub_code).nil?
          string += decode(sub_code)
          sub_code = ''
        end
      end
      string
    end

    def [](char)
      encode(char)
    end

    private

    def prepare_lookup
      lookup = {}
      @root.walk do |node, code|
        lookup[code] = node.symbol if node.leaf?
      end
      lookup
    end
  end

  class HuffmanNode
    attr_accessor :weight, :symbol, :left, :right, :parent

    def initialize(params = {})
      @weight = params[:weight] || 0
      @symbol = params[:symbol] || ''
      @left   = params[:left]   || nil
      @right  = params[:right]  || nil
      @parent = params[:parent] || nil
    end

    def walk(&block)
      walk_node('', &block)
    end

    def walk_node(code, &block)
      yield(self, code)
      @left.walk_node(code + '0', &block) unless @left.nil?
      @right.walk_node(code + '1', &block) unless @right.nil?
    end

    def leaf?
      @symbol != ''
    end

    def internal?
      @symbol == ''
    end

    def root?
      internal? and @parent.nil?
    end
  end

  class HuffmanNodeQueue
    attr_accessor :nodes, :root

    def initialize(list)
      frequencies = {}
      list.each do |c|
        frequencies[c] ||= 0
        frequencies[c] += 1
      end
      @nodes = []
      frequencies.each do |c, w|
        @nodes << HuffmanNode.new(:symbol => c, :weight => w)
      end
      generate_tree
    end

    def find_smallest(not_this)
      smallest = nil
      for i in 0..@nodes.size - 1
        if i == not_this
          next
        end
        if smallest.nil? or @nodes[i].weight < @nodes[smallest].weight
          smallest = i
        end
      end
      smallest
    end

    def generate_tree
      while @nodes.size > 1
        node1 = self.find_smallest(-1)
        node2 = self.find_smallest(node1)
        hn1 = @nodes[node1]
        hn2 = @nodes[node2]
        new = merge_nodes(hn1, hn2)
        @nodes.delete(hn1)
        @nodes.delete(hn2)
        @nodes.concat(Array.new(1,new))
      end
      @root = @nodes.first
    end

    def merge_nodes(node1, node2)
      left = node1
      right = node2
      node = HuffmanNode.new(:weight => left.weight + right.weight, :left => left, :right => right)
      left.parent = right.parent = node
      node
    end
  end
end
