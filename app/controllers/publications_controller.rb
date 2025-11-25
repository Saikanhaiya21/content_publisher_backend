class PublicationsController < ApplicationController
  before_action :authenticate_request!, except: [:published]
  before_action :set_publication, only: [:show, :update, :destroy, :restore]

  # GET /publications
  def index
    pubs = current_user.publications.active.search(params[:title]).status_filter(params[:status])
    pubs = pubs.order(created_at: :desc)

    render json: { items: pubs }, status: :ok
  end

  # POST /publications
  def create
    pub = current_user.publications.build(publication_params)
    if pub.save
      render json: pub, status: :created
    else
      render json: { errors: pub.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /publications/:id
  def show
    render json: @publication, status: :ok
  end

  # PUT /publications/:id
  def update
    if @publication.update(publication_params)
      render json: @publication, status: :ok
    else
      render json: { errors: @publication.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /publications/:id (soft delete)
  def destroy
    @publication.update(deleted_at: Time.current)
    head :no_content
  end

  # DELETE /publications/bulk_destroy?ids[]=1&ids[]=2
  def bulk_destroy
    ids = params[:ids] || []
    current_user.publications.where(id: ids).update_all(deleted_at: Time.current)
    head :no_content
  end

  # PUT /publications/:id/restore
  def restore
    if @publication.deleted_at.present?
      @publication.update(deleted_at: nil)
      render json: @publication, status: :ok
    else
      render json: { error: 'Not deleted' }, status: :unprocessable_entity
    end
  end

  # GET /public/published
  def published
    pubs = Publication.published_only.order(created_at: :desc)

    render json: { items: pubs }, status: :ok
  end

  private

  def set_publication
    @publication = current_user.publications.find(params[:id])
  end

  def publication_params
    params.require(:publication).permit(:title, :content, :status)
  end
end
