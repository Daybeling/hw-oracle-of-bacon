require 'byebug'                # optional, may be helpful
require 'open-uri'              # allows open('http://...') to return body
require 'cgi'                   # for escaping URIs
require 'nokogiri'              # XML parser
require 'active_model'          # for validations

class OracleOfBacon

  class InvalidError < RuntimeError ; end
  class NetworkError < RuntimeError ; end
  class InvalidKeyError < RuntimeError ; end

  attr_accessor :from, :to
  attr_reader :api_key, :response, :uri

  include ActiveModel::Validations
  validates_presence_of :from
  validates_presence_of :to
  validates_presence_of :api_key
  validate :from_does_not_equal_to

  def from_does_not_equal_to
    # YOUR CODE HERE
  end

  def initialize(api_key='')
    # your code here
  end

  def find_connections
    make_uri_from_arguments
    begin
      xml = URI.parse(uri).read
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
      Net::ProtocolError => e
      # convert all of these into a generic OracleOfBacon::NetworkError,
      #  but keep the original error message
      # your code here
    end
    # your code here: create the OracleOfBacon::Response object
  end

  def make_uri_from_arguments
    @uri = "http://oracleofbacon.org/cgi-bin/xml?p=#{CGI.escape(@api_key)}&a=#{CGI.escape(@from)}&b=#{CGI.escape(@to)}"
  end

  class Response
    attr_reader :type, :data
    # create a Response object from a string of XML markup.
    def initialize(xml)
      @doc = Nokogiri::XML(xml)
      parse_response
    end

    private

    def parse_response
      if ! @doc.xpath('/error').empty?
        parse_error_response
      # your code here: 'elsif' clauses to handle other responses
      # for responses not matching the 3 basic types, the Response
      # object should have type 'unknown' and data 'unknown response'
      end
    end
    def parse_error_response
      @type = :error
      @data = 'Unauthorized access'
    end

    def parse_graph_response
      @type = :graph
      a = @doc.css('actor').map do |i|
        i.xpath('.//text()').text
      end
      m = @doc.css('movie').map do |i|
        i.xpath('.//text()').text
      end
      @data = a.zip(m).flatten.compact
    end
    def parse_spellcheck_response
      @type = :spellcheck
      s = @doc.css('match').map do |i|
        i.xpath('.//text()').text
      end
      @data = s
    end
    def parse_unknown_response
      @type = :unknown
      @data = 'unknown response type'
    end
    def draw_graph
      @type = :graph
      c=0
      @data.each do |i|
        if (c%2).eql?(0)
          if !c.eql?(@data.length - 1)
            print "#{i} \\_"
          else
            puts "#{i}"
          end
        else
          puts " #{i}"
          if c < @data.length
          puts "\t\t/"
          end
        end
        c+=1
      end
    end
  end
end
