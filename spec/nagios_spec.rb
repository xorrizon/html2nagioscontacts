require 'spec_helper'

module Html2nagioscontacts
  describe Nagios do

    describe '#prepare_source' do

      subject (:prepared_source) { Nagios.new
        .prepare_source(
          [{'name' => "Max Mustermann", 'email' => "max@mustermann.tv" }, {'name' => "Weir}d ch$rs in name", 'email' => "blu b%@muste*rmann.tv" }]
        )
      }
      it { should have(2).items }
      it "removes special chars" do
        prepared_source[1]['name'].should eq "Weir_dch_rsinname"
        prepared_source[1]['alias'].should eq "Weir_d ch_rs in name"
        prepared_source[1]['email'].should eq "blub@mustermann.tv"
      end

    end

    describe 'create_contacts' do
      subject (:defines) {
        Nagios.new.create_contacts([{'name' => "name1", 'email' => "name1@blub.com"}, {'name' => "name2", 'email' => "name2@blub.com"}]).defines
      }
      its ("first.type.value") {should eq "Contact"}
      its ("first.nodes") {should have(4).items }
    end

  end
end
