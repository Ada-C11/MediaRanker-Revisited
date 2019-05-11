require "test_helper"

describe WorksController do
  let(:existing_work) { works(:album) }

  describe "root" do
    it "succeeds with all media types" do
      get root_path

      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      only_book = works(:poodr)
      only_book.destroy

      get root_path

      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all do |work|
        work.destroy
      end

      get root_path

      must_respond_with :success
    end

    it "renders even if a user isn't logged in" do
      delete logout_path
      expect(session[:user_id]).must_equal nil

      get root_path

      must_respond_with :success
    end
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    before do
      @user = users(:dan)
    end
    it "succeeds for a logged in user when there are works" do
      perform_login(@user)
      get works_path

      must_respond_with :success
    end

    it "succeeds for a logged in user when there are no works" do
      perform_login(@user)
      Work.all do |work|
        work.destroy
      end

      get works_path

      must_respond_with :success
    end

    it "sends a guest user to the root path with an error message" do
      get works_path

      expect(flash[:status]).must_equal :error
      expect(flash[:message]).wont_be_nil

      must_redirect_to root_path
    end
  end

  describe "new" do
    it "succeeds" do
      get new_work_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a work with valid data for a real category" do
      new_work = { work: { title: "Dirty Computer", category: "album" } }

      expect {
        post works_path, params: new_work
      }.must_change "Work.count", 1

      new_work_id = Work.find_by(title: "Dirty Computer").id

      must_respond_with :redirect
      must_redirect_to work_path(new_work_id)
    end

    it "renders bad_request and does not update the DB for bogus data" do
      bad_work = { work: { title: nil, category: "book" } }

      expect {
        post works_path, params: bad_work
      }.wont_change "Work.count"

      must_respond_with :bad_request
    end

    it "renders 400 bad_request for bogus categories" do
      INVALID_CATEGORIES.each do |category|
        invalid_work = { work: { title: "Invalid Work", category: category } }

        proc { post works_path, params: invalid_work }.wont_change "Work.count"

        Work.find_by(title: "Invalid Work", category: category).must_be_nil
        must_respond_with :bad_request
      end
    end
  end

  describe "show" do
    before do
      @user = users(:dan)
    end
    it "succeeds for a logged in user with an extant work ID" do
      perform_login(@user)
      get work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      destroyed_id = existing_work.id
      existing_work.destroy

      get work_path(destroyed_id)

      must_respond_with :not_found
    end

    it "sends a guest user back to the root path with an error message" do
      #TODO
    end

    it "works for a logged in user" do
    end
  end

  describe "edit" do
    it "succeeds for an extant work ID" do
      get edit_work_path(existing_work.id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      get edit_work_path(bogus_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    it "succeeds for valid data and an extant work ID" do
      updates = { work: { title: "Dirty Computer" } }

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"
      updated_work = Work.find_by(id: existing_work.id)

      updated_work.title.must_equal "Dirty Computer"
      must_respond_with :redirect
      must_redirect_to work_path(existing_work.id)
    end

    it "renders bad_request for bogus data" do
      updates = { work: { title: nil } }

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"

      work = Work.find_by(id: existing_work.id)

      must_respond_with :not_found
    end

    it "renders 404 not_found for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      put work_path(bogus_id), params: { work: { title: "Test Title" } }

      must_respond_with :not_found
    end
  end

  describe "destroy" do
    it "succeeds for an extant work ID" do
      expect {
        delete work_path(existing_work.id)
      }.must_change "Work.count", -1

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "renders 404 not_found and does not update the DB for a bogus work ID" do
      bogus_id = existing_work.id
      existing_work.destroy

      expect {
        delete work_path(bogus_id)
      }.wont_change "Work.count"

      must_respond_with :not_found
    end
  end

  describe "upvote" do
    before do
      @user = users(:dan)
      @work = Work.first
      @start_count = Vote.count
    end
    it "redirects to the work page if no user is logged in" do
      post upvote_path(@work)
      expect(flash[:result_text]).wont_be_nil
      expect(@start_count).must_equal Vote.count

      must_redirect_to work_path(@work)
    end

    it "redirects to the work page after the user has logged out" do
      perform_login(@user)
      expect(session[:user_id]).must_equal @user.id
      delete logout_path
      expect(session[:user_id]).must_equal nil

      post upvote_path(@work)
      expect(flash[:result_text]).wont_be_nil
      expect(@start_count).must_equal Vote.count

      must_redirect_to work_path(@work)
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      before_vote = @work.votes.count
      perform_login(@user)
      expect(session[:user_id]).must_equal @user.id

      post upvote_path(@work)
      expect(Vote.count).must_equal @start_count + 1
      expect(@work.votes.count).must_equal before_vote + 1

      must_redirect_to work_path(@work)
    end

    it "redirects to the work page if the user has already voted for that work" do
      perform_login(@user)
      expect(session[:user_id]).must_equal @user.id

      post upvote_path(@work)
      expect(Vote.count).must_equal @start_count + 1
      post upvote_path(@work)
      expect(Vote.count).must_equal @start_count + 1

      must_redirect_to work_path(@work)
    end
  end
end
