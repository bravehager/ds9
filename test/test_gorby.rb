require 'minitest/autorun'
require 'gorby'

class TestGorby < Minitest::Test
  def test_sanity
    assert Gorby::NGHTTP2_PROTO_VERSION_ID
  end

  def test_session_allocation
    assert Gorby::Session.new Gorby::Events.new
  end

  def test_session_submit_settings
    session = Gorby::Session.new Gorby::Events.new
    session.submit_settings [[Gorby::Settings::MAX_CONCURRENT_STREAMS, 100]]
  end

  def test_send
    called = false
    session = Gorby::Session.new Class.new(Gorby::Events) {
      define_method :send_event do |string|
        called = string
        super(string)
      end
    }.new

    session.submit_settings [[Gorby::Settings::MAX_CONCURRENT_STREAMS, 100]]
    session.send
    assert called
  end

  def test_want_read?
    session = Gorby::Session.new Gorby::Events.new
    session.submit_settings [[Gorby::Settings::MAX_CONCURRENT_STREAMS, 100]]
    assert_predicate session, :want_write?
  end

  def test_want_write?
    session = Gorby::Session.new Gorby::Events.new
    session.submit_settings [[Gorby::Settings::MAX_CONCURRENT_STREAMS, 100]]
    assert_predicate session, :want_write?

    session = Gorby::Session.new Gorby::Events.new
    refute_predicate session, :want_write?
  end
end
