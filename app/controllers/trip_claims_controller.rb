class TripClaimsController < ApplicationController
  load_and_authorize_resource :trip_claim, :only => :dashboard
  load_and_authorize_resource :trip_ticket, :except => :dashboard
  load_and_authorize_resource :trip_claim, :through => :trip_ticket, :except => :dashboard
  
  # GET /trip_claims
  # GET /trip_claims.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @trip_claims }
      format.js
    end
  end

  # GET /trip_claims/1
  # GET /trip_claims/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trip_claim }
    end
  end

  # GET /trip_claims/new
  # GET /trip_claims/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip_claim }
    end
  end

  # GET /trip_claims/1/edit
  def edit
  end

  # POST /trip_claims
  # POST /trip_claims.json
  def create
    @trip_claim.claimant = current_user.provider unless current_user.has_admin_role?
    @trip_claim.status = :pending
    respond_to do |format|
      if @trip_claim.save
        @trip_claim.reload
        notice = 'Trip claim was successfully created.'
        notice += ' Your claim has been automatically approved.' if @trip_claim.approved?
        format.html { redirect_to @trip_ticket, notice: notice }
        format.json { render json: @trip_claim, status: :created, location: @trip_claim }
      else
        format.html { render action: "new" }
        format.json { render json: @trip_claim.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /trip_claims/1
  # PUT /trip_claims/1.json
  def update
    respond_to do |format|
      if @trip_claim.update_attributes(params[:trip_claim])
        format.html { redirect_to @trip_ticket, notice: 'Trip claim was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @trip_claim.errors, status: :unprocessable_entity }
      end
    end
  end

  def rescind
    @trip_claim.rescind!
    
    respond_to do |format|
      format.html { redirect_to @trip_ticket, notice: 'Trip claim was successfully rescinded.' }
      format.json { head :no_content }
    end
  end

  # PUT /trip_claims/1/approve
  def approve
    @trip_claim.approve!
    
    respond_to do |format|
      format.html { redirect_to @trip_ticket, notice: 'Trip claim was successfully approved.' }
      format.json { head :no_content }
    end
  end

  # PUT /trip_claims/1/decline
  def decline
    @trip_claim.decline!
    
    respond_to do |format|
      format.html { redirect_to @trip_ticket, notice: 'Trip claim was successfully declined.' }
      format.json { head :no_content }
    end
  end
  
  def dashboard; end
end
