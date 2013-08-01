require 'spec_helper'
require 'tempfile'

describe Html2nagioscontacts::Parser do

  before :all do
    Html2nagioscontacts::Settings.load_default
    @text = <<-EOF
      <p />
      <h2><a name="Contact_List"></a> Contact List </h2>
      The following list is automatically parsed by nagios regularly.
      Please keep the formatting <ul>
      <li> Maxine Testerin, <a href="mailto&#58;maxine&#64;qmail&#46;com">maxine&#64;qmail.com</a>
      </li> <li> Max Mustermann, <a href="mailto&#58;max&#64;mustermann&#46;tv">max&#64;mustermann.tv</a>
      </li> <li> <a href="mailto&#58;luke&#64;blub&#46;vom">luke&#64;blub.com</a>, Verkehrter Lukas
      </li> <li> No Mail, <a href="mailto&#58;nomail">nomail</a>
      </li></ul>
      <p />
      EOF
  end

  before :each do
    @parser = Html2nagioscontacts::Parser.new
    @parser.text= @text
  end

  it 'should return correct contacts' do
    result = @parser.parse

    result.should include( {'name' => "Max Mustermann", 'email' => "max@mustermann.tv" } )
    result.should include( {'name' => "Maxine Testerin", 'email' => "maxine@qmail.com" } )
    result.should include( {'name' => "Verkehrter Lukas", 'email' => "luke@blub.com" } )

  end

  it 'should not contain entries without email adresses' do
    result = @parser.parse
    result.should have(3).items
  end

  # or url
  it 'should load a a file' do
    file = Tempfile.new 'test'
    file.write @text
    file.close
    @parser.text = nil
    @parser.url = file.path
    result = @parser.parse
    result.should have(3).items
  end

end



