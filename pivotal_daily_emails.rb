module PivotalDailyEmails

  def self.send
    path = File.expand_path(File.join(File.dirname(__FILE__), "mails"))
    templates = Dir.glob("#{path}/*.erb")
    templates.each do |template|
      email = Email.new(template)
      email.prepare.deliver!
    end
  end

  class Email
    require 'erb'
    require 'yaml'
    require 'tracker_api'
    require 'mail'
    require 'date'

    def initialize(path)
      parse File.read(path)
    end

    attr_reader :meta, :delivered, :finished, :started, :blocked, :questions

    def prepare
      client = TrackerApi::Client.new(token: ENV['PIVOTAL_KEY'])
      project  = client.project(@meta['id'])
      @delivered = project.stories(with_state: 'delivered')
      @finished  = project.stories(with_state: 'finished')
      @started   = project.stories(with_state: 'started')
      @blocked   = project.stories(filter: 'state:started,unstarted label:blocked')
      @questions = project.stories(filter: 'state:started,unstarted label:question')
      @body = ERB.new(@content).result(binding)
      self
    end

    def deliver!
      if @meta["debug"]
        puts '---'
        puts "From: #{@meta['from']}"
        puts "To: #{recipients}"
        puts "Subject: #{subject_line}"
        puts '---'
        puts @body
        return
      end
      Mail.defaults do
        delivery_method :smtp, address: 'smtp.mandrillapp.com', port: 587,
                          user_name: ENV['MANDRILL_USER'], password: ENV['MANDRILL_PASS']
      end
      mail = Mail.new
      mail.from @meta['from']
      mail.to      recipients
      mail.subject subject_line
      mail.body @body
      mail.deliver!
    end

    def output_stories(stories)
      result = []
      stories.each do |story|
        result << ""
        result << story.name
        result << story.url
      end
      result.join "\n\t"
    end

    private
      def recipients
        @meta['to'].join(',')
      end

      def subject_line
        "#{@meta['subject']} - #{Date.today.strftime('%d %B %Y')}"
      end

      def parse(template)
        split_content = template.split(/^---/, 3)
        split_content.shift
        @meta = YAML::load split_content.shift
        @content = split_content.shift
      end
  end
end
