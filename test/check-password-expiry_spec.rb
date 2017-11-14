require 'sensu-plugins-chage/util'

# sample `chage -l` outputs
chage_never_text = <<-HEREDOC
Last password change					: Jul 04, 2017
Password expires					: never
Password inactive					: never
Account expires						: never
Minimum number of days between password change		: 0
Maximum number of days between password change		: 99999
Number of days of warning before password expires	: 7
HEREDOC

chage_date_text = <<-HEREDOC
Last password change					: Jul 04, 2017
Password expires					: Oct 03, 2017
Password inactive					: never
Account expires						: never
Minimum number of days between password change		: 0
Maximum number of days between password change		: 99999
Number of days of warning before password expires	: 7
HEREDOC

# rubocop:disable Metrics/BlockLength, Layout/IndentHeredoc
describe SensuPluginsChage::Util do
  subject { Class.new.include(SensuPluginsChage::Util).new }

  describe '::parse_chage_password_expiry' do
    it 'handles never' do
      expect(subject.parse_chage_password_expiry(chage_never_text)).to eq 'never'
    end

    it 'handles date' do
      output = subject.parse_chage_password_expiry(chage_date_text)
      expect(output).to be_a Date
      expect(output.iso8601).to eq '2017-10-03'
    end
  end

  describe '::days_to_password_expiry' do
    it 'handles never' do
      expect(subject.days_to_password_expiry(Date.iso8601('2016-01-01'), chage_never_text)).to eq 'never'
    end

    it 'doesn\'t return a fraction with valid expiry date' do
      expect(subject.days_to_password_expiry(Date.iso8601('2017-09-03'), chage_date_text)).to be_a Fixnum
    end

    it 'handles expiry date of 1 month' do
      expect(subject.days_to_password_expiry(Date.iso8601('2017-09-03'), chage_date_text)).to eq 30
    end

    it 'handles expiry date of 1 day' do
      expect(subject.days_to_password_expiry(Date.iso8601('2017-10-02'), chage_date_text)).to eq 1
    end

    it 'handles expiry date same day' do
      expect(subject.days_to_password_expiry(Date.iso8601('2017-10-03'), chage_date_text)).to eq 0
    end

    it 'handles expiry date in past' do
      expect(subject.days_to_password_expiry(Date.iso8601('2017-10-04'), chage_date_text)).to eq -1
    end
  end
end
