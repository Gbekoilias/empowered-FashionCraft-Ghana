import std/[times, tables, sequtils, options, strformat]
import chronos

type
  EventType* = enum
    Training, Workshop, Assessment

  Event* = object
    id*: string
    title*: string
    eventType*: EventType
    startTime*: DateTime
    duration*: Duration
    capacity*: int
    participants*: seq[string]
    resources*: seq[string]

  Schedule* = ref object
    events*: Table[string, Event]
    resources*: Table[string, seq[DateTime]]

  ScheduleError* = object of CatchableError

proc newSchedule*(): Schedule =
  result = Schedule()
  result.events = initTable[string, Event]()
  result.resources = initTable[string, seq[DateTime]]()

proc isResourceAvailable(s: Schedule, resource: string, start: DateTime, 
                        duration: Duration): bool =
  if resource notin s.resources:
    return true
  
  let endTime = start + duration
  for bookedTime in s.resources[resource]:
    if bookedTime >= start and bookedTime <= endTime:
      return false
  true

proc scheduleEvent*(s: Schedule, event: Event): Future[Option[Event]] {.async.} =
  # Check resource availability
  for resource in event.resources:
    if not s.isResourceAvailable(resource, event.startTime, event.duration):
      return none(Event)

  # Check for time conflicts
  for existingEvent in s.events.values:
    if existingEvent.startTime <= event.startTime and 
       event.startTime <= existingEvent.startTime + existingEvent.duration:
      return none(Event)

  # Book resources
  for resource in event.resources:
    if resource notin s.resources:
      s.resources[resource] = @[]
    s.resources[resource].add(event.startTime)

  s.events[event.id] = event
  return some(event)

proc cancelEvent*(s: Schedule, eventId: string): Future[bool] {.async.} =
  if eventId notin s.events:
    return false

  let event = s.events[eventId]
  # Release resources
  for resource in event.resources:
    if resource in s.resources:
      s.resources[resource] = s.resources[resource].filterIt(it != event.startTime)

  s.events.del(eventId)
  return true

proc addParticipant*(s: Schedule, eventId, participant: string): bool =
  if eventId notin s.events:
    return false

  var event = s.events[eventId]
  if event.participants.len >= event.capacity:
    return false

  if participant notin event.participants:
    event.participants.add(participant)
    s.events[eventId] = event
    return true

  false

proc removeParticipant*(s: Schedule, eventId, participant: string): bool =
  if eventId notin s.events:
    return false

  var event = s.events[eventId]
  let idx = event.participants.find(participant)
  if idx != -1:
    event.participants.delete(idx)
    s.events[eventId] = event
    return true

  false

proc getUpcomingEvents*(s: Schedule, days: int = 7): seq[Event] =
  let currentTime = now()
  let endTime = currentTime + initDuration(days = days)
  
  result = @[]
  for event in s.events.values:
    if event.startTime >= currentTime and event.startTime <= endTime:
      result.add(event)
  
  result.sort do (a, b: Event) -> int:
    cmp(a.startTime, b.startTime)

proc getResourceUtilization*(s: Schedule): Table[string, float] =
  result = initTable[string, float]()
  let totalHours = 24.0 * 7.0  # Weekly hours
  
  for resource, bookings in s.resources:
    let usedHours = bookings.len.float
    result[resource] = (usedHours / totalHours) * 100.0

let schedule = newSchedule()
let event = Event(
  id: "TR001",
  title: "Leadership Workshop",
  eventType: Training,
  startTime: now() + initDuration(days = 1),
  duration: initDuration(hours = 3),
  capacity: 20,
  resources: @["Room A", "Projector"]
)
discard await schedule.scheduleEvent(event)