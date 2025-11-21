class_name WorkerComponents
extends Resource

enum WorkerState {
    IDLE,
    WALKING,          # <--- The new generic state
    PICKING_UP,       # Was PICKING_UP_AMMO
    DROPPING_OFF,     # Was DROPPING_OFF_AT_WAREHOUSE
    INSERTING         # Was INSERTING_AMMO
}
