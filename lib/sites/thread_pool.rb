class Sites::ThreadPool
  attr_reader :executor

  def initialize
    @executor = Concurrent::FixedThreadPool.new(
        3,
        auto_terminate: false,
        fallback_policy: :abort
    )
  end

  def self.instance
    @@instance ||= new
  end

  def post(&block)
    @executor.post(&block)
  end

  def wait_termination
    @executor.shutdown
    @executor.wait_for_termination
  end

  private_class_method :new
end