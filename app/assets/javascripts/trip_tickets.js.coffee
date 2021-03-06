# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class window.TripTicketsMap
  map = null
  marker = null
  mapOptions =
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP
  pickUpLocation = null
  pickUpLocationSet = false
  dropOffLocation = null
  dropOffLocationSet = false
  
  setPickUpLocation: (location) ->
    pickUpLocation = location
    pickUpLocationSet = true

  setDropOffLocation: (location) ->
    dropOffLocation = location
    dropOffLocationSet = true

  init: (pickUpLocationAddress, dropOffLocationAddress) ->
    pickUpLocationSet = false
    dropOffLocationSet = false
    @locateAddress(pickUpLocationAddress, @setPickUpLocation)
    @locateAddress(dropOffLocationAddress, @setDropOffLocation)

  showTwoPoints: ->
    # console.log "pickUpLocation", pickUpLocation
    # console.log "dropOffLocation", dropOffLocation
    if pickUpLocation? and dropOffLocation?
      mapOptions.center = new google.maps.LatLng(
        (pickUpLocation.geometry.location.lat() + dropOffLocation.geometry.location.lat()) / 2,
        (pickUpLocation.geometry.location.lng() + dropOffLocation.geometry.location.lng()) / 2
      )
      @showMap()
      directionsService = new google.maps.DirectionsService()
      directionsDisplay = new google.maps.DirectionsRenderer(
        # suppressMarkers: true,
        # suppressInfoWindows: true
      )
      directionsDisplay.setMap(map)
      request =
        origin: pickUpLocation.geometry.location
        destination: dropOffLocation.geometry.location
        travelMode: google.maps.DirectionsTravelMode.DRIVING
      directionsService.route request, (response, status) =>
        if status == google.maps.DirectionsStatus.OK
          directionsDisplay.setDirections(response)
    else 
      if pickUpLocation?
        mapOptions.center = pickUpLocation.geometry.location
        @showMap()
        @setMarker pickUpLocation
      else if dropOffLocation?
        mapOptions.center = dropOffLocation.geometry.location
        @showMap()
        @setMarker dropOffLocation
        
    return @map
  
  locateAddress: (address, setter, lastAddressFetched = false) ->
    geocoder = new google.maps.Geocoder()
    geocoder.geocode address, (results, status) =>
      # console.log "Looking for:", address
      # console.log "Found:", results
      if status == google.maps.GeocoderStatus.OK
        # console.log "Returning:", results[0]
        setter results[0]
      else
        # console.log "Unable to locate address", status
        setter null
      @showTwoPoints() if pickUpLocationSet and dropOffLocationSet
  
  showMap: ->
    # console.log mapOptions
    map = new google.maps.Map $("#map-canvas")[0], mapOptions
    
  setMarker: (position) ->
    # console.log "setMarker", position
    marker = new google.maps.Marker({
      map: map,
      position: position.geometry.location,
      title: position.formatted_address
    });

$ ->
  # Make this a global variable so we can reset it from the AJAX dashboard
  window.dirtyFilterForm = false

  $('form.apply-filter input[type="submit"]').css({ position: 'absolute', left: '-9999px'})

  $('form.apply-filter select').change ->
    $(this).parent('form').submit()

  $('form.form-filter input, form.form-filter select').change (evt) ->
    window.dirtyFilterForm = true

  # when the saved filter form is submitted, make sure any modified values in the
  # ad-hoc form are included by wiping out the old hidden fields and replacing them
  $(document).on "submit", 'div.saved-filter-form form', (evt) ->
    if window.dirtyFilterForm == true
      $saved_filter_form = $(this)
      $saved_filter_form.children('input[name^="filter[data]"]').remove()
      $.each $('form.form-filter').serializeArray(), (i, field) ->
        if field.name.indexOf('trip_ticket_filters') == 0 && field.value && field.value.length > 0
          new_field_name = field.name.replace(/^trip_ticket_filters/, "filter[data]");
          $saved_filter_form.append('<input type="hidden" value="'+field.value+'" name="'+new_field_name+'">')

  $('.advanced-filters, .saved-filter-form').openClose({
    activeClass: 'active',
    opener: '.opener',
    slider: '.slide',
    animSpeed: 400,
    effect: 'slide'
  });
