#!/usr/bin/env ruby

require 'yaml'
require 'pp'
require 'gibbon'
require 'optparse'
require 'base64'

class Chimper
  
  attr :from_name,:reply_to

  def initialize(args)
    # load config
    @config = YAML.load_file('../_gibbon.yaml')
    @from_name = args[:from_name] if args[:from_name]
    @reply_to = args[:reply_to] if args[:reply_to]

    @gibbon = Gibbon::Request.new(api_key: @config['api_key'])
  end

  # required:
  # :list_id
  # :segment_id
  # :subject_line
  # :title
  def create_regular_campaign(args)
    create_campaign_request = {
      type: "regular",
      recipients: {
        list_id: args[:list_id],
        segment_opts: {
          saved_segment_id: args[:segment_id]
        }
      },
      settings: {
        subject_line: args[:subject_line],
        title: args[:title],
        from_name: @from_name,
        reply_to: @reply_to,
      }
    }
    template = {
      template: {
        id: get_template_id_from_name(args[:template]),
        sections: {
           "title": args[:title],
           "content": args[:message],
           "image_lnk": "<img alt=\"\" src=\"#{args[:featured_image_link]}\" class=\"mcnImage\" style=\"max-width:427px; padding-bottom: 0; display: inline !important; vertical-align: bottom;\" align=\"middle\" width=\"427\"/>",
           "link_to_article": "<a class=\"mcnButton\" title=\"Aller à l'article\" href=\"#{args[:link]}\" target=\"_self\" style=\"font-weight:bold;letter-spacing:-.5px;line-height:100%;text-align:center;text-decoration:none;color:#FFFFFF;\">Aller à l'article</a>"
        }
      }
    }
    @campaign = @gibbon.campaigns.create(body: create_campaign_request)
    @gibbon.campaigns(@campaign.body['id']).content.upsert(body: template)
  end

  def get_lists
    @gibbon.lists.retrieve.body['lists']
  end
  def get_templates
    @gibbon.templates.retrieve.body['templates']
  end

  def get_template_id_from_name(template)
    self.get_templates.each do |tmpl|
      return tmpl['id'] if tmpl['name'] == template
    end
  end

  def get_segments_from_list(list_id)
    @gibbon.lists(list_id).segments.retrieve.body['segments']
  end

  def upload_image(file)
    file_upload = {
      name: File::basename(file),
      file_data: Base64::encode64(File.read(file))
    }
    @last_image_upload = @gibbon.file_manager.files.create(body: file_upload)
  end

end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: chimper.rb [options]"

  opts.on("-l", "--list list", "Mailchimp list") do |l|
    options[:list] = l
  end
  opts.on("-t", "--title title", "Article title in mail") do |s|
    options[:title] = s
  end
  opts.on("-s", "--subject subject", "Subject of mail") do |s|
    options[:subject] = s
  end
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on("-S", "--segment segment_name", "Name of segment to restrict mail") do |s|
    options[:segment] = s
  end
  opts.on("-f", "--featured-image filename", "Featured image to display in mail") do |s|
    options[:featured_image] = s
  end
  opts.on("-m", "--message txt", "Mail message") do |s|
    options[:message] = s
  end
  opts.on("--message-file snippet.html", "Mail message from file") do |s|
    options[:message] = File.read(s)
  end
  opts.on("--template tmpl", "Template to use") do |s|
    options[:template] = s
  end
  opts.on("--link url", "Direct URL to article") do |s|
    options[:link] = s
  end
end.parse!

chimper = Chimper.new(:from_name => 'Hélène de Le Crochet d\'Argent',
                      :reply_to  => 'contact@lecrochetdargent.fr')

upload = chimper.upload_image(options[:featured_image])
##pp chimper.get_templates
#exit

# get segment id from name
chimper.get_lists.each do |list|
  options[:list_id] = list['id'] if list['name'] == options[:list]
  chimper.get_segments_from_list(list['id']).each do |segment|
    options[:segment_id] = segment['id'] if segment['name'] == options[:segment]
  end
end

chimper.create_regular_campaign(:list_id             => options[:list_id],
                                :subject_line        => options[:subject],
                                :segment_id          => options[:segment_id],
                                :title               => options[:title],
                                :link                => options[:link],
                                :template            => options[:template],
                                :message             => options[:message],
                                :featured_image_link => upload.body['full_size_url'])

