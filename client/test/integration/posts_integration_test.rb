require 'test_helper'
require 'drb'
require 'rest_test_helper'

class PostIntegrationTest < ActiveSupport::TestCase
  # def setup
  #   @server = RestTestHelper::Server::Rails.new('/Users/owenou/workspace/testing_rest_web_services_with_rails/server', 'test')
  #   @server.start

  #   DRb.start_service
  #   @base =  DRbObject.new nil, "druby://127.0.0.1:61677"
  # end

  # def teardown
  #   # @server.stop
  # end

  test "rollback remote data in a transaction" do
    assert_equal 0, Post.all.size

    begin
      puts "before"
      # begin_db_transaction
      puts "after"
      Post.create(:title => "title", :body => "content")
      assert_equal 1, Post.all.size
    ensure
      # rollback_db_transaction
    end

    assert_equal 0, Post.all.size
  end

  private

  def begin_db_transaction
    @base.connection.increment_open_transactions
    @base.connection.transaction_joinable = false
    @base.connection.begin_db_transaction
  end

  def rollback_db_transaction
    @base.connection.rollback_db_transaction
    @base.connection.decrement_open_transactions
    @base.clear_active_connections!
  end
end
