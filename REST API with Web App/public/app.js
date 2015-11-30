// Integrate third party app: ui-calendar (includes FullCalendar)
var app = angular.module('calendarApp', ['ui.calendar', 'ui.bootstrap']);

app.controller('CalendarCtrl',
   function($scope, $compile, $timeout, $http, uiCalendarConfig) {

    $scope.evnt = {
        title: "",
        description: "",
        start: new Date(),
        end: new Date(),
        venue: "",
    };

    $scope.edit = {
        id: "",
        title: "",
        description: "",
        start: new Date(),
        end: new Date(),
        venue: "",
    };

    // $scope.eventSource = {
    //         url: "http://www.google.com/calendar/feeds/usa__en%40holiday.calendar.google.com/public/basic",
    //         className: 'gcal-event',           // an option!
    //         currentTimezone: 'America/Chicago' // an option!
    // };
    /* event source that contains custom events on the scope */
    $scope.events = {
            url: "http://130.233.42.84:8080/api/events/"
    };

    /* alert on eventClick */
    $scope.alertOnEventClick = function( date, jsEvent, view){
        if(date.end==null) {
            date.end = date.start;
        }
        $scope.edit = {
            id: date._id,
            title: date.title,
            description: date.description,
            start: new Date(date.start),
            end: new Date(date.end),
            venue: date.venue,
        };
        console.log($scope.edit.id)
    };
    /* add custom event*/
    $scope.addEvent = function() {
      $http.post("http://130.233.42.84:8080/api/events", $scope.evnt)
            .success(function(data) {
                $scope.evnt = {
                    title: "",
                    description: "",
                    start: new Date(),
                    end: new Date(),
                    venue: "",
                };
                document.location.reload(true);
            })
            .error(function(data) {
                console.log("Error: " + data)
            });
    };
    /* remove event */
    $scope.removeEvent = function(index) {
      $http.delete("http://130.233.42.84:8080/api/events/"+$scope.edit.id)
            .success(function(data) {
                $scope.edit = {
                    id: "",
                    title: "",
                    description: "",
                    start: new Date(),
                    end: new Date(),
                    venue: "",
                };
                document.location.reload(true);
            })
            .error(function(data) {
                console.log("Error: " + data)
            });
    };
    $scope.updateEvent = function() {
      $http.put("http://130.233.42.84:8080/api/events/"+$scope.edit.id, $scope.edit)
            .success(function(data) {
                $scope.edit = {
                    id: "",
                    title: "",
                    description: "",
                    start: new Date(),
                    end: new Date(),
                    venue: "",
                };
                document.location.reload(true);
            })
            .error(function(data) {
                console.log("Error: " + data)
            });
    };
    /* config object */
    $scope.uiConfig = {
      calendar:{
        height: 450,
        editable: true,
        timezone: 'local',
        header:{
          left: 'title',
          center: '',
          right: 'today prev,next'
        },
        eventClick: $scope.alertOnEventClick,
        eventDrop: $scope.alertOnDrop,
        eventResize: $scope.alertOnResize,
        eventRender: $scope.eventRender
      }
    };
    // $scope.eventSources = [$scope.events, $scope.eventSource];
    $scope.eventSources = [$scope.events];
});
/* EOF */
