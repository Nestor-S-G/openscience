// Configuration for the wheel
// Takes in two functions and returns the config
function wheelConfig(alertPrize, playSound, prizeMoney)
{
    return {
        'outerRadius'     : 212,        // Set outer radius so wheel fits inside the background.
        'innerRadius'     : 75,         // Make wheel hollow so segments don't go all way to center.
        'textFontSize'    : 24,         // Set default font size for the segments.
        'textOrientation' : 'horizontal', // Make text vertial so goes down from the outside of wheel.
        'textAlignment'   : 'outer',    // Align text to outside of wheel.
        'numSegments'     : 16,         // Specify number of segments.
        'segments'        :             // Define segments including colour and text.
        [                               // font size and test colour overridden on backrupt segments.
            {'fillStyle' : '#ee1c24', 'text' : `$${(prizeMoney + 2).toFixed(2)}`, 'value': 2},
            {'fillStyle' : '#3cb878', 'text' : `$${(prizeMoney + 1.70).toFixed(2)}`, 'value': 1.7},
            {'fillStyle' : '#f6989d', 'text' : `$${(prizeMoney + 0.7).toFixed(2)}`, 'value': 0.7},
            {'fillStyle' : '#00aef0', 'text' : `$${(prizeMoney + 0.5).toFixed(2)}`, 'value': 0.5},
            {'fillStyle' : '#f26522', 'text' : `$${(prizeMoney + 0.1).toFixed(2)}`, 'value': 0.1},
            {'fillStyle' : '#e70697', 'text' : `$${(prizeMoney + 1.9).toFixed(2)}`, 'value': 1.9},
            {'fillStyle' : '#f6989d', 'text' : `$${(prizeMoney + 1.3).toFixed(2)}`, 'value': 1.3},
            {'fillStyle' : '#3cb878', 'text' : `$${(prizeMoney + 1.8).toFixed(2)}`, 'value': 1.8},
            {'fillStyle' : '#f26522', 'text' : `$${(prizeMoney + 1.2).toFixed(2)}`, 'value': 1.2},
            {'fillStyle' : '#fff200', 'text' : `$${(prizeMoney + 1.6).toFixed(2)}`, 'value': 1.6},
            {'fillStyle' : '#00aef0', 'text' : `$${(prizeMoney + 1.5).toFixed(2)}`, 'value': 1.5},
            {'fillStyle' : '#f6989d', 'text' : `$${(prizeMoney + 1.4).toFixed(2)}`, 'value': 1.4},
            {'fillStyle' : '#f26522', 'text' : `$${(prizeMoney + 0.8).toFixed(2)}`, 'value': 0.8},
            {'fillStyle' : '#3cb878', 'text' : `$${(prizeMoney + 0.6).toFixed(2)}`, 'value': 0.6},
            {'fillStyle' : '#a186be', 'text' : `$${(prizeMoney + 0.9).toFixed(2)}`, 'value': 0.9},
            {'fillStyle' : '#fff200', 'text' : `$${(prizeMoney + 1.1).toFixed(2)}`, 'value': 1.1}
        ],
        'animation' :           // Specify the animation to use.
        {
            'type'     : 'spinToStop',
            'duration' : 10,    // Duration in seconds.
            'spins'    : 3,     // Default number of complete spins.
            'callbackFinished' : alertPrize,
            'callbackSound'    : playSound,   // Function to call when the tick sound is to be triggered.
            'soundTrigger'     : 'pin'        // Specify pins are to trigger the sound, the other option is 'segment'.
        },
        'pins' :				// Turn pins on.
        {
            'number'     : 16,
            'fillStyle'  : 'silver',
            'outerRadius': 4,
        }
    }
}

export default wheelConfig;