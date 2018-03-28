require 'digest'
require 'json'

class Blockchain
  class Transaction
    attr_reader :sender, :recipient, :amount

    def initialize(sender:, recipient:, amount:)
      @sender = sender
      @recipient = recipient
      @amount = amount
    end

    def to_h
      {
        sender: sender,
        recipient: recipient,
        amount: amount
      }
    end
  end

  class Block
    attr_reader :proof, :previous_hash, :index, :timestamp, :transactions

    def initialize(proof:, previous_hash: nil, index:, timestamp:, transactions:)
      @proof = proof
      @previous_hash = previous_hash
      @index = index
      @timestamp = timestamp
      @transactions = transactions
    end

    def hash
      @hash ||= Digest::SHA256.hexdigest( JSON.dump(as_sorted_lists) )
    end

    def to_h
      {
        proof: proof,
        previous_hash: previous_hash,
        index: index,
        timestamp: timestamp,
        transactions: transactions.map(&:to_h)
      }
    end

    def to_json
      JSON.dump(to_h)
    end

    def as_sorted_lists
      to_h.tap { |h| h[:transactions] = h[:transactions].map(&:sort) }.sort
    end
  end

  def initialize
    @chain = []
    @current_transactions = []

    # genesis block
    new_block(proof: 100, previous_hash: 1)
  end

  def new_block(proof:, previous_hash:)
    chain << Block.new(
      proof: proof,
      previous_hash: previous_hash,
      index: next_block_index,
      timestamp: Time.now.to_i,
      transactions: current_transactions
    )

    reset_transactions

    last_block
  end

  def new_transaction(sender:, recipient:, amount:)
    current_transactions << Transaction.new(sender: sender, recipient: recipient, amount: amount)

    next_block_index
  end

  private

  attr_reader :chain, :current_transactions

  def next_block_index
    chain.length.next
  end

  def last_block
    chain[-1]
  end

  def reset_transactions
    current_transactions = []
  end
end
