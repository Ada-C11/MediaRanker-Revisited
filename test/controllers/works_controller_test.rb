require "test_helper"

describe WorksController do
  let(:existing_work) { works(:album) }
  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]
  describe "Guest Users " do
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

    describe "show" do
      it "requires a login to show a work" do
        get work_path(existing_work.id)

        must_redirect_to root_path
      end
    end

    describe "index" do
      it "requires a login to show list of works" do
        get works_path
        must_redirect_to root_path
      end
    end

    describe "new" do
      it "requires a login to instantiate a Work" do
        get new_work_path
        must_redirect_to root_path
      end
    end

    describe "create" do
      it "requires a login to create a work" do
        new_work = { work: { title: "Dirty Computer", category: "album" } }

        expect {
          post works_path, params: new_work
        }.wont_change "Work.count"

        new_work = Work.find_by(title: "Dirty Computer")
        new_work.must_be_nil
        must_redirect_to root_path
      end
    end

    describe "edit" do
      # test for work has to belong to user that created it below
      it "requires a login to edit a work" do
        get edit_work_path(-1)
        must_redirect_to root_path
      end
    end

    describe "edit" do
      # test for work has to belong to user that created it below
      it "requires a login to edit a work" do
        get edit_work_path(existing_work.id)
        must_redirect_to root_path
      end
    end

    describe "update" do
      # test for work has to belong to user that created it below
      it "requires a login to update a work" do
        updates = { work: { title: "Dirty Computer" } }

        expect {
          put work_path(existing_work), params: updates
        }.wont_change "Work.count"
        updated_work = Work.find_by(id: existing_work.id)
        updated_work.title.must_equal existing_work.title
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "destroy" do
      # test for work has to belong to user that created it below
      it "requires a login to destroy a work" do
        expect {
          delete work_path(existing_work.id)
        }.wont_change "Work.count"
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end
  end

  describe "Logged in Users" do
    before do
      perform_login(User.first)
    end

    describe "index" do
      # have to login to get access - success for after logging in, failure if not logged in
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

    describe "show" do
      # have to login to get access - success for after logging in, failure if not logged in
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

      it "won't let a user edit another user's work" do
        perform_login(users(:kari))
        get edit_work_path(existing_work.id)

        must_respond_with :bad_request

        flash[:status].must_equal :failure
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

      it "won't let a user update another user's work" do
        perform_login(users(:kari))
        updates = { work: { title: "Dirty Computer" } }

        put work_path(existing_work), params: updates

        must_respond_with :bad_request

        flash[:status].must_equal :failure
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

      it "won't let a user delete another user's work" do
        perform_login(users(:kari))

        delete work_path(existing_work.id)

        must_respond_with :bad_request

        flash[:status].must_equal :failure
      end
    end
    describe "upvote" do
      it "redirects to the work page if no user is logged in" do
        delete logout_path
        post upvote_path(existing_work)

        flash[:status].must_equal :failure

        flash[:result_text].must_include "logged in"

        must_redirect_to root_path
      end

      it "redirects to the work page after the user has logged out" do
        delete logout_path

        session[:user_id].must_be_nil

        must_redirect_to root_path
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        perform_login(User.first)
        fresh_work = works(:movie)

        post upvote_path(fresh_work.id)

        flash[:status].must_equal :success
        flash[:result_text].must_include "Successfully upvoted"
      end

      it "redirects to the work page if the user has already voted for that work" do
        perform_login(User.first)

        post upvote_path(existing_work.id)

        flash[:status].must_equal :failure
        flash[:messages][:user].must_include "has already voted for this work"
      end
    end
  end
end
