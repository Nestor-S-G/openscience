// Extract duration from config

// Custom durations to speed up debugging
export const speed_debug_durations = {
    break_block: 0.1,
    break_sequence: 0.1,
    screen_1: 0.1,
    screen_2: 0.1,
    screen_3: 0.1,
    aaron_mood_info: 0.1,
    game: {
        aaron_bad_mood: 0.2,
        choice: 10, // Allow more time for decision to avoid missed trials while debugging
        missed_trial: 0.5,
        pass: 0,
        result: 0.1,
        spin: 0.5,
    }, 
    reminder: 1,
};

function extractDurationFromType(extracted_duration, duration_type)
{
    extracted_duration.screen_1 = duration_type.screen_1;
    extracted_duration.screen_2 = duration_type.screen_2;
    extracted_duration.screen_3 = duration_type.screen_3;
    extracted_duration.aaron_mood_info = duration_type.aaron_mood_info;
    extracted_duration.game = duration_type.game;

    return extracted_duration;
}

// Extracts durations depending on practice or experiment
export function extractDurations(durations, type)
{

    let extracted_duration = {};

    const {break_block, break_sequence} = durations;

    extracted_duration.break_block = break_block;
    extracted_duration.break_sequence = break_sequence;

    if (type === "practice")
    {
        const {practice} = durations;
        extracted_duration.reminder = practice.reminder;
        extracted_duration = extractDurationFromType(extracted_duration, practice);
    }
    else
    {
        const {experiment} = durations;
        extracted_duration.reminder = experiment.reminder;

        // Slow or normal
        let durationType = experiment.slow;
        if (type === "normal")
        {
            durationType = experiment.normal;
        }
        extracted_duration = extractDurationFromType(extracted_duration, durationType);
    }

    return extracted_duration;
}

function checkSlowRound(slow_trials) 
{
    return slow_trials > 0;
}

// Choose between practice, slow or normal durations
export function selectDuration(config, practice_flag, slow_trials)
{
    const type = practice_flag ? "practice" : 
        ( checkSlowRound(slow_trials) ? "slow" : "normal" );

    return extractDurations(config.params.duration, type);
}