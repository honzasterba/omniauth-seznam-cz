# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'omniauth-seznam-cz'
require 'stringio'

describe OmniAuth::Strategies::SeznamCz do
  let(:request) { double('Request', params: {}, cookies: {}, env: {}) }
  let(:app) do
    lambda do
      [200, {}, ['Hello.']]
    end
  end

  subject do
    OmniAuth::Strategies::SeznamCz.new(app, 'appid', 'secret', @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) do
        request
      end
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe '#client_options' do
    it 'has correct site' do
      expect(subject.client.site).to eq('https://oauth2.googleapis.com')
    end

    it 'has correct authorize_url' do
      expect(subject.client.options[:authorize_url]).to eq('https://accounts.google.com/o/oauth2/auth')
    end

    it 'has correct token_url' do
      expect(subject.client.options[:token_url]).to eq('/token')
    end

    describe 'overrides' do
      context 'as strings' do
        it 'should allow overriding the site' do
          @options = { client_options: { 'site' => 'https://example.com' } }
          expect(subject.client.site).to eq('https://example.com')
        end

        it 'should allow overriding the authorize_url' do
          @options = { client_options: { 'authorize_url' => 'https://example.com' } }
          expect(subject.client.options[:authorize_url]).to eq('https://example.com')
        end

        it 'should allow overriding the token_url' do
          @options = { client_options: { 'token_url' => 'https://example.com' } }
          expect(subject.client.options[:token_url]).to eq('https://example.com')
        end
      end

      context 'as symbols' do
        it 'should allow overriding the site' do
          @options = { client_options: { site: 'https://example.com' } }
          expect(subject.client.site).to eq('https://example.com')
        end

        it 'should allow overriding the authorize_url' do
          @options = { client_options: { authorize_url: 'https://example.com' } }
          expect(subject.client.options[:authorize_url]).to eq('https://example.com')
        end

        it 'should allow overriding the token_url' do
          @options = { client_options: { token_url: 'https://example.com' } }
          expect(subject.client.options[:token_url]).to eq('https://example.com')
        end
      end
    end
  end

  describe '#authorize_options' do
    %i[access_type hd login_hint prompt scope state device_id device_name].each do |k|
      it "should support #{k}" do
        @options = { k => 'http://someval' }
        expect(subject.authorize_params[k.to_s]).to eq('http://someval')
      end
    end

    describe 'redirect_uri' do
      it 'should default to nil' do
        @options = {}
        expect(subject.authorize_params['redirect_uri']).to eq(nil)
      end

      it 'should set the redirect_uri parameter if present' do
        @options = { redirect_uri: 'https://example.com' }
        expect(subject.authorize_params['redirect_uri']).to eq('https://example.com')
      end
    end

    describe 'access_type' do
      it 'should default to "offline"' do
        @options = {}
        expect(subject.authorize_params['access_type']).to eq('offline')
      end

      it 'should set the access_type parameter if present' do
        @options = { access_type: 'online' }
        expect(subject.authorize_params['access_type']).to eq('online')
      end
    end

    describe 'hd' do
      it 'should default to nil' do
        expect(subject.authorize_params['hd']).to eq(nil)
      end

      it 'should set the hd (hosted domain) parameter if present' do
        @options = { hd: 'example.com' }
        expect(subject.authorize_params['hd']).to eq('example.com')
      end

      it 'should set the hd parameter and work with nil hd (gmail)' do
        @options = { hd: nil }
        expect(subject.authorize_params['hd']).to eq(nil)
      end

      it 'should set the hd parameter to * if set (only allows G Suite emails)' do
        @options = { hd: '*' }
        expect(subject.authorize_params['hd']).to eq('*')
      end
    end

    describe 'login_hint' do
      it 'should default to nil' do
        expect(subject.authorize_params['login_hint']).to eq(nil)
      end

      it 'should set the login_hint parameter if present' do
        @options = { login_hint: 'john@example.com' }
        expect(subject.authorize_params['login_hint']).to eq('john@example.com')
      end
    end

    describe 'prompt' do
      it 'should default to nil' do
        expect(subject.authorize_params['prompt']).to eq(nil)
      end

      it 'should set the prompt parameter if present' do
        @options = { prompt: 'consent select_account' }
        expect(subject.authorize_params['prompt']).to eq('consent select_account')
      end
    end

    describe 'request_visible_actions' do
      it 'should default to nil' do
        expect(subject.authorize_params['request_visible_actions']).to eq(nil)
      end

      it 'should set the request_visible_actions parameter if present' do
        @options = { request_visible_actions: 'something' }
        expect(subject.authorize_params['request_visible_actions']).to eq('something')
      end
    end

    describe 'include_granted_scopes' do
      it 'should default to nil' do
        expect(subject.authorize_params['include_granted_scopes']).to eq(nil)
      end

      it 'should set the include_granted_scopes parameter if present' do
        @options = { include_granted_scopes: 'true' }
        expect(subject.authorize_params['include_granted_scopes']).to eq('true')
      end
    end

    describe 'scope' do
      it 'should expand scope shortcuts' do
        @options = { scope: 'calendar' }
        expect(subject.authorize_params['scope']).to eq('https://www.googleapis.com/auth/calendar')
      end

      it 'should leave base scopes as is' do
        @options = { scope: 'profile' }
        expect(subject.authorize_params['scope']).to eq('profile')
      end

      it 'should join scopes' do
        @options = { scope: 'profile,email' }
        expect(subject.authorize_params['scope']).to eq('profile email')
      end

      it 'should deal with whitespace when joining scopes' do
        @options = { scope: 'profile, email' }
        expect(subject.authorize_params['scope']).to eq('profile email')
      end

      it 'should set default scope to email,profile' do
        expect(subject.authorize_params['scope']).to eq('email profile')
      end

      it 'should support space delimited scopes' do
        @options = { scope: 'profile email' }
        expect(subject.authorize_params['scope']).to eq('profile email')
      end

      it 'should support extremely badly formed scopes' do
        @options = { scope: 'profile email,foo,steve yeah http://example.com' }
        expect(subject.authorize_params['scope']).to eq('profile email https://www.googleapis.com/auth/foo https://www.googleapis.com/auth/steve https://www.googleapis.com/auth/yeah http://example.com')
      end
    end

    describe 'state' do
      it 'should set the state parameter' do
        @options = { state: 'some_state' }
        expect(subject.authorize_params['state']).to eq('some_state')
        expect(subject.authorize_params[:state]).to eq('some_state')
        expect(subject.session['omniauth.state']).to eq('some_state')
      end

      it 'should set the omniauth.state dynamically' do
        allow(subject).to receive(:request) { double('Request', params: { 'state' => 'some_state' }, env: {}) }
        expect(subject.authorize_params['state']).to eq('some_state')
        expect(subject.authorize_params[:state]).to eq('some_state')
        expect(subject.session['omniauth.state']).to eq('some_state')
      end
    end

    describe 'overrides' do
      it 'should include top-level options that are marked as :authorize_options' do
        @options = { authorize_options: %i[scope foo request_visible_actions], scope: 'http://bar', foo: 'baz', hd: 'wow', request_visible_actions: 'something' }
        expect(subject.authorize_params['scope']).to eq('http://bar')
        expect(subject.authorize_params['foo']).to eq('baz')
        expect(subject.authorize_params['hd']).to eq(nil)
        expect(subject.authorize_params['request_visible_actions']).to eq('something')
      end

      describe 'request overrides' do
        %i[access_type hd login_hint prompt scope state].each do |k|
          context "authorize option #{k}" do
            let(:request) { double('Request', params: { k.to_s => 'http://example.com' }, cookies: {}, env: {}) }

            it "should set the #{k} authorize option dynamically in the request" do
              @options = { k: '' }
              expect(subject.authorize_params[k.to_s]).to eq('http://example.com')
            end
          end
        end

        describe 'custom authorize_options' do
          let(:request) { double('Request', params: { 'foo' => 'something' }, cookies: {}, env: {}) }

          it 'should support request overrides from custom authorize_options' do
            @options = { authorize_options: [:foo], foo: '' }
            expect(subject.authorize_params['foo']).to eq('something')
          end
        end
      end
    end
  end

  describe '#authorize_params' do
    it 'should include any authorize params passed in the :authorize_params option' do
      @options = { authorize_params: { request_visible_actions: 'something', foo: 'bar', baz: 'zip' }, hd: 'wow', bad: 'not_included' }
      expect(subject.authorize_params['request_visible_actions']).to eq('something')
      expect(subject.authorize_params['foo']).to eq('bar')
      expect(subject.authorize_params['baz']).to eq('zip')
      expect(subject.authorize_params['hd']).to eq('wow')
      expect(subject.authorize_params['bad']).to eq(nil)
    end
  end

  describe '#token_params' do
    it 'should include any token params passed in the :token_params option' do
      @options = { token_params: { foo: 'bar', baz: 'zip' } }
      expect(subject.token_params['foo']).to eq('bar')
      expect(subject.token_params['baz']).to eq('zip')
    end
  end

  describe '#token_options' do
    it 'should include top-level options that are marked as :token_options' do
      @options = { token_options: %i[scope foo], scope: 'bar', foo: 'baz', bad: 'not_included' }
      expect(subject.token_params['scope']).to eq('bar')
      expect(subject.token_params['foo']).to eq('baz')
      expect(subject.token_params['bad']).to eq(nil)
    end
  end

  describe '#callback_url' do
    let(:base_url) { 'https://example.com' }

    it 'has the correct default callback path' do
      allow(subject).to receive(:full_host) { base_url }
      allow(subject).to receive(:script_name) { '' }
      expect(subject.send(:callback_url)).to eq(base_url + '/auth/google_oauth2/callback')
    end

    it 'should set the callback path with script_name if present' do
      allow(subject).to receive(:full_host) { base_url }
      allow(subject).to receive(:script_name) { '/v1' }
      expect(subject.send(:callback_url)).to eq(base_url + '/v1/auth/google_oauth2/callback')
    end

    it 'should set the callback_path parameter if present' do
      @options = { callback_path: '/auth/foo/callback' }
      allow(subject).to receive(:full_host) { base_url }
      allow(subject).to receive(:script_name) { '' }
      expect(subject.send(:callback_url)).to eq(base_url + '/auth/foo/callback')
    end
  end

  describe '#info' do
    let(:client) do
      OAuth2::Client.new('abc', 'def') do |builder|
        builder.request :url_encoded
        builder.adapter :test do |stub|
          stub.get('/oauth2/v3/userinfo') { [200, { 'content-type' => 'application/json' }, response_hash.to_json] }
        end
      end
    end
    let(:access_token) { OAuth2::AccessToken.from_hash(client, {}) }
    before { allow(subject).to receive(:access_token).and_return(access_token) }

    context 'with verified email' do
      let(:response_hash) do
        { email: 'something@domain.invalid', email_verified: true }
      end

      it 'should return equal email and unverified_email' do
        expect(subject.info[:email]).to eq('something@domain.invalid')
        expect(subject.info[:unverified_email]).to eq('something@domain.invalid')
      end
    end

    context 'with unverified email' do
      let(:response_hash) do
        { email: 'something@domain.invalid', email_verified: false }
      end

      it 'should return nil email, and correct unverified email' do
        expect(subject.info[:email]).to eq(nil)
        expect(subject.info[:unverified_email]).to eq('something@domain.invalid')
      end
    end
  end

  describe '#extra' do
    let(:client) do
      OAuth2::Client.new('abc', 'def') do |builder|
        builder.request :url_encoded
        builder.adapter :test do |stub|
          stub.get('/oauth2/v3/userinfo') { [200, { 'content-type' => 'application/json' }, '{"sub": "12345"}'] }
        end
      end
    end
    let(:access_token) { OAuth2::AccessToken.from_hash(client, {}) }

    before { allow(subject).to receive(:access_token).and_return(access_token) }

    describe 'id_token' do
      shared_examples 'id_token issued by valid issuer' do |issuer|
        context 'when the id_token is passed into the access token' do
          let(:token_info) do
            {
              'abc' => 'xyz',
              'exp' => Time.now.to_i + 3600,
              'nbf' => Time.now.to_i - 60,
              'iat' => Time.now.to_i,
              'aud' => 'appid',
              'iss' => issuer
            }
          end
          let(:id_token) { JWT.encode(token_info, 'secret') }
          let(:access_token) { OAuth2::AccessToken.from_hash(client, 'id_token' => id_token) }

          it 'should include id_token when set on the access_token' do
            expect(subject.extra).to include(id_token: id_token)
          end



          it 'should include id_info when id_token is set on the access_token by default' do
            expect(subject.extra).to include(id_info: token_info)
          end
        end
      end

      it_behaves_like 'id_token issued by valid issuer', 'accounts.google.com'
      it_behaves_like 'id_token issued by valid issuer', 'https://accounts.google.com'

      context 'when the id_token is missing' do
        it 'should not include id_token' do
          expect(subject.extra).not_to have_key(:id_token)
        end

        it 'should not include id_info' do
          expect(subject.extra).not_to have_key(:id_info)
        end
      end
    end

    describe 'raw_info' do
      context 'when skip_info is true' do
        before { subject.options[:skip_info] = true }

        it 'should not include raw_info' do
          expect(subject.extra).not_to have_key(:raw_info)
        end
      end

      context 'when skip_info is false' do
        before { subject.options[:skip_info] = false }

        it 'should include raw_info' do
          expect(subject.extra[:raw_info]).to eq('sub' => '12345')
        end
      end
    end
  end


end
