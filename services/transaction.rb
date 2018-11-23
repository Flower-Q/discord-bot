module Transaction
  private

  def transaction(model_class, &proc)
    TransactionContext.new(model_class, &proc)
  end

  class TransactionContext
    def initialize(model_class, &proc)
      @model_class = model_class
      @procs = []
      @using_transaction = Mongoid.default_client.cluster.replica_set?
      pipe(&proc) if block_given?
    end

    def pipe(&proc)
      @procs << proc
      self
    end

    def do_transaction
      @model_class.with_session do |session|
        session.start_transaction if @using_transaction

        result = @procs.inject(Some(nil)) do |res, proc|
          res.flat_map { proc.call }
        end

        result.each { session.commit_transaction }
              .or_else { session.abort_transaction } if @using_transaction

        result
      end
    end
  end
  private_constant :TransactionContext
end
