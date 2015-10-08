
require 'spec_helper'

describe MoviesController do
  describe 'edit page for appropriate Movie' do
    it 'When I go to the edit page for the Movie, it should be loaded' do
      movie = double('Movie')
      Movie.should_receive(:find).with('27').and_return(movie )

      # expecting: Movie.find("13")  # return that mock
      # contoller edit route
      get :edit, {:id => '27'}
      # the route is Unblocked, at real situation, the edit page of rottenpotatoes is loaded with 200
      response.should be_success
    end
    it 'update and save and redirect' do
      mock = double('Movie')
      allow(mock).to receive(:update_attributes!)
      allow(mock).to receive(:title)
      allow(mock).to receive(:director)
      
      mock2 = double('Movie')
      Movie.should_receive(:find).with('27').and_return(mock)
      
      # at "update" post with following content
      post(:update, {:id => '27', :movie => mock2 })
      response.should redirect_to(movie_path(mock))
    end
    it 'When I follow "Find Movies With Same Director", I should be on the Similar Movies page for the Movie' do
      mock = double('Movie')
      allow(mock).to receive(:director).and_return('Bowei Liu')
      
      similarMocks = [double('Movie'), double('Movie')]
      
      Movie.should_receive(:find).with('27').and_return(mock)
      Movie.should_receive(:find_all_by_director).with(mock.director).and_return(similarMocks)
      get :similar, {:id => '27'}
    end
    it 'should show Movie by id' do
      mock = double('Movie')
      Movie.should_receive(:find).with('27').and_return(mock)
      get :show, {:id => '27'}
    end
    it 'should redirect to index if movie does not have a director' do
      mock = double('Movie')
      # this double instanceo f Movie has no director
      allow(mock).to receive(:director).and_return(nil)
      allow(mock).to receive(:title).and_return("Bowei attend CSCE 606")
      
      Movie.should_receive(:find).with('27').and_return(mock)
      get :similar, {:id => '27'}
      # return to movies_path, the /movies
      response.should redirect_to(movies_path)
    end
    it 'should be possible to create movie' do
      movie = double('Movie')
      allow(movie).to  receive(:title)
      
      Movie.should_receive(:create!).and_return(movie)
      post :create, {:movie => movie}
      response.should redirect_to(movies_path)
    end
    it 'should be possible to destroy movie' do
      movie = double('Movie')
      allow(movie).to receive(:title)
      
      Movie.should_receive(:find).with('27').and_return(movie)
      
      movie.should_receive(:destroy)
      post :destroy, {:id => '27'}
      response.should redirect_to(movies_path)
    end
    it 'should redirect if sort order has been changed' do
      session[:sort] = 'release_date'
      get :index, {:sort => 'title'}
      response.should redirect_to(movies_path(:sort => 'title'))
    end
    it 'should be possible to order by release date' do
      get :index, {:sort => 'release_date'}
      response.should redirect_to(movies_path(:sort => 'release_date'))
    end
    it 'should redirect if selected ratings are changed' do
      get :index, {:ratings => {:G => 1}}
      # I just wirte codes, appeared in controllers, add .should before them
      response.should redirect_to(movies_path(:ratings => {:G => 1}))
    end
    it 'should remove noDirector message from session' do
      session[:noDirector] = 'test'
      get :index
      session[:noDirector].should == nil
    end
    it 'should call database to get movies' do
      Movie.should_receive(:find_all_by_rating)
      get :index
    end
  end
end