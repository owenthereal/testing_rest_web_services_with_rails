require 'minitest/autorun'

module RestTestHelper
  class MiniTestWithHooks < MiniTest::Unit
    def before_suites
    end

    def after_suites
    end

    def before_suite
    end

    def after_suite
    end

    def _run_suites(suites, type)
      begin
        before_suites
        super(suites, type)
      ensure
        after_suites
      end
    end

    def _run_suite(suite, type)
      begin
        before_suite
        super(suite, type)
      ensure
        after_suite
      end
    end
  end

  class Runner < MiniTestWithHooks
    def before_suites
      @server = RestTestHelper::Server::Rails.new('/Users/owenou/workspace/testing_rest_web_services_with_rails/server', 'test')
      @server.start

      DRb.start_service
      @remote_base =  DRbObject.new nil, "druby://0.0.0.0:61191"
    end

    def after_suites
      @server.stop
    end

    def before_suite
      begin_db_transaction
    end

    def after_suite
      rollback_db_transaction
    end

    private

    def begin_db_transaction
      @remote_base.connection.increment_open_transactions
      @remote_base.connection.transaction_joinable = false
      @remote_base.connection.begin_db_transaction
    end

    def rollback_db_transaction
      @remote_base.connection.rollback_db_transaction
      @remote_base.connection.decrement_open_transactions
      @remote_base.clear_active_connections!
    end
  end
end
