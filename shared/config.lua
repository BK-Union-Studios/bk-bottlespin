Config = {}

Config.Items = {
    ['bottle'] = {
        model = `prop_beer_bottle`,
        label = 'Beer Bottle'
    }
}

Config.SpinDuration = {min = 5000, max = 30000} -- ms
Config.SpinSpeed = 15.0
Config.InteractDistance = 2.0
Config.InteractKey = 38 -- 'E'

Config.UI = {
    position = 'right-center',
    backgroundColor = 'rgba(0, 0, 0, 0.85)',
    textColor = '#FFFFFF',
    borderRadius = '12px',
    offsetTop = '4vh'
}

Config.PickupCommand = 'pbottle' 

Config.Locales = {
    ['spin_bottle'] = 'Spin the bottle',
    ['spin_key'] = 'E',
    ['spin_notification'] = 'Bottle is spinning',
    ['bottle_placed'] = 'Bottle placed on the ground',
    ['pickup_bottle'] = '/pbottle - Pick up bottle',
    ['bottle_picked_up'] = 'Bottle picked up',
    ['no_bottle_nearby'] = 'No bottle nearby'
}