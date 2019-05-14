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
  end

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe "index" do
    describe "logged-in users" do
      before do
        perform_login(users(:dee))
      end

      it "succeeds when there are works" do
        get works_path

        must_respond_with :success
      end

      it "succeeds when there are no works" do
        Work.all do |work|
          work.destroy
        end

        get works_path

        must_respond_with :success
      end
    end

    describe "guest users" do
      it "redirects a guest user" do
        get works_path

        must_respond_with :redirect
        must_redirect_to root_path
        check_flash(:error)
      end
    end
  end

  describe "new" do
    it "succeeds with a logged in user" do
      perform_login(users(:dan))
      get new_work_path

      must_respond_with :success
    end

    it "redirects a guest user" do
      get new_work_path

      must_respond_with :redirect
      must_redirect_to root_path
      check_flash(:error)
    end
  end

  describe "create" do
    it "redirects a guest user" do
      new_work = {work: {title: "Dirty Computer", category: "album"}}
      post works_path, params: new_work

      must_respond_with :redirect
      must_redirect_to root_path
      check_flash(:error)
    end

    describe "logged-in users" do
      before do
        perform_login(users(:kari))
      end

      it "creates a work with valid data for a real category" do
        new_work = {work: {title: "Dirty Computer", category: "album"}}

        expect {
          post works_path, params: new_work
        }.must_change "Work.count", 1

        new_work_id = Work.find_by(title: "Dirty Computer").id

        must_respond_with :redirect
        must_redirect_to work_path(new_work_id)
      end

      it "renders bad_request and does not update the DB for bogus data" do
        bad_work = {work: {title: nil, category: "book"}}

        expect {
          post works_path, params: bad_work
        }.wont_change "Work.count"

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        INVALID_CATEGORIES.each do |category|
          invalid_work = {work: {title: "Invalid Work", category: category}}

          proc { post works_path, params: invalid_work }.wont_change "Work.count"

          Work.find_by(title: "Invalid Work", category: category).must_be_nil
          must_respond_with :bad_request
        end
      end
    end
  end

  describe "show" do
    it "redirects a guest user" do
      get work_path(existing_work.id)

      must_respond_with :redirect
      must_redirect_to root_path
      check_flash(:error)
    end

    describe "logged-in users" do
      before do
        perform_login(users(:dan))
      end

      it "succeeds for an extant work ID" do
        get work_path(existing_work.id)

        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        destroyed_id = existing_work.id
        existing_work.destroy

        get work_path(destroyed_id)

        must_respond_with :not_found
      end
    end
  end

  describe "edit" do
    it "redirects a guest user" do
      get edit_work_path(existing_work.id)

      must_respond_with :redirect
      must_redirect_to root_path
      check_flash(:error)
    end

    describe "logged-in users" do
      before do
        perform_login(users(:dan))
      end

      it "succeeds for an existant work ID" do
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
  end

  describe "update" do
    it "redirects a guest user" do
      updates = {work: {title: "Dirty Computer"}}
      put work_path(existing_work), params: updates

      must_respond_with :redirect
      must_redirect_to root_path
      check_flash(:error)
    end

    describe "logged-in users" do
      before do
        perform_login(users(:kari))
      end

      it "succeeds for valid data and an extant work ID" do
        updates = {work: {title: "Dirty Computer"}}

        expect {
          put work_path(existing_work), params: updates
        }.wont_change "Work.count"
        updated_work = Work.find_by(id: existing_work.id)

        updated_work.title.must_equal "Dirty Computer"
        must_respond_with :redirect
        must_redirect_to work_path(existing_work.id)
      end

      it "renders bad_request for bogus data" do
        updates = {work: {title: nil}}

        expect {
          put work_path(existing_work), params: updates
        }.wont_change "Work.count"

        work = Work.find_by(id: existing_work.id)

        must_respond_with :not_found
      end

      it "renders 404 not_found for a bogus work ID" do
        bogus_id = existing_work.id
        existing_work.destroy

        put work_path(bogus_id), params: {work: {title: "Test Title"}}

        must_respond_with :not_found
      end
    end
  end

  describe "destroy" do
    it "redirects a guest user" do
      expect {
        delete work_path(existing_work.id)
      }.wont_change "Work.count"

      must_respond_with :redirect
      must_redirect_to root_path
      check_flash(:error)
    end

    describe "logged-in users" do
      before do
        perform_login(users(:kari))
      end

      it "succeeds for an existing work ID" do
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
  end

  describe "upvote" do
    let(:user) { users(:dee) }

    it "redirects to the work page if no user is logged in" do
      before_upvote = Work.first.votes.count
      post upvote_path(Work.first)

      check_flash(:error)
      expect(Work.first.votes.count).must_equal before_upvote
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to the home page after the user has logged out" do
      before_upvote = Work.first.vote_count
      perform_login(user)

      post upvote_path(Work.first)
      after_upvote = Work.first.vote_count

      check_flash
      expect(after_upvote).must_equal (before_upvote + 1)
      must_respond_with :redirect
      must_redirect_to work_path(Work.first)

      delete logout_path

      expect(session[:user_id]).must_be_nil

      post upvote_path(Work.first)
      check_flash(:error)
      expect(Work.first.votes.count).must_equal after_upvote
      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succeeds for a logged-in user and a fresh user-vote pair" do
      before_upvote = Work.first.vote_count
      perform_login(user)

      post upvote_path(Work.first)
      after_upvote = Work.first.vote_count

      check_flash
      expect(after_upvote).must_equal (before_upvote + 1)
      must_respond_with :redirect
      must_redirect_to work_path(Work.first)

      delete logout_path

      expect(session[:user_id]).must_be_nil

      perform_login(users(:kari))

      expect(session[:user_id]).must_equal users(:kari).id
      post upvote_path(Work.first)
      after_upvote = Work.first.vote_count

      check_flash
      expect(after_upvote).must_equal (before_upvote + 2)
      must_respond_with :redirect
      must_redirect_to work_path(Work.first)
    end

    it "redirects to the work page if the user has already voted for that work" do
      before_upvote = Work.first.vote_count
      perform_login(user)

      post upvote_path(Work.first)
      after_upvote = Work.first.vote_count

      check_flash
      expect(after_upvote).must_equal (before_upvote + 1)
      must_respond_with :redirect
      must_redirect_to work_path(Work.first)

      post upvote_path(Work.first)
      before_second_upvote = after_upvote
      after_upvote = Work.first.vote_count

      expect(after_upvote).must_equal (before_second_upvote)
      check_flash(:error)
      must_respond_with :redirect
      must_redirect_to work_path(Work.first)
    end
  end
end
