require 'spec_helper'

module Html2nagioscontacts

  describe Settings do

    before :all do
      Settings.load_default
    end

    it 'should have dynamic methods' do
      Settings._settings['drop_privilidges'].should_not be_nil

      Settings.drop_privilidges.should_not be_nil
    end

    it 'should load the default_config' do
      Settings._settings.should_not be_nil
      Settings.drop_privilidges.should be_true
      Settings.drop_privilidges_user.should eq("nagios")
    end
  end

end
