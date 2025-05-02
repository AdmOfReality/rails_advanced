require 'rails_helper'

shared_examples_for 'votable' do
  let(:user) { create(:user) }
  let(:votable) do
    if described_class == Answer
      create(:answer, question: create(:question, author: user), author: user)
    elsif described_class == Question
      create(:question, author: user)
    else
      raise "Unknown votable class: #{described_class}"
    end
  end
  let(:other_user) { create(:user) }

  describe '#vote_by' do
    it 'returns vote by given user' do
      votable.votes.create!(user: other_user, value: 1)
      expect(votable.vote_by(other_user)).to be_present
    end

    it 'returns nil if no vote found' do
      expect(votable.vote_by(other_user)).to be_nil
    end
  end

  describe '#rating' do
    it 'returns sum of vote values' do
      votable.votes.create!(user: create(:user), value: 1)
      votable.votes.create!(user: create(:user), value: -1)
      expect(votable.rating).to eq(0)
    end
  end

  describe '#vote!' do
    it 'creates new vote if none exists' do
      expect do
        votable.vote!(other_user, 1)
      end.to change(votable.votes, :count).by(1)
    end

    it 'replaces existing vote if different value' do
      votable.votes.create!(user: other_user, value: 1)
      expect do
        votable.vote!(other_user, -1)
      end.not_to change(votable.votes, :count)
      expect(votable.vote_by(other_user).value).to eq(-1)
    end

    it 'raises error if same vote already exists' do
      votable.vote!(other_user, 1)
      expect do
        votable.vote!(other_user, 1)
      end.to raise_error(Votable::AlreadyVotedError, 'User already voted with value 1')
    end

    it 'returns rating after successful vote' do
      expect(votable.vote!(other_user, 1)).to eq(1)
    end
  end

  describe '#cancel_vote!' do
    it 'removes vote and returns new rating' do
      votable.votes.create!(user: other_user, value: 1)
      expect do
        result = votable.cancel_vote!(other_user)
        expect(result).to eq(0)
      end.to change(votable.votes, :count).by(-1)
    end

    it 'raises error if vote not found' do
      expect do
        votable.cancel_vote!(other_user)
      end.to raise_error(Votable::VoteNotFoundError, 'No vote found to cancel')
    end
  end
end
