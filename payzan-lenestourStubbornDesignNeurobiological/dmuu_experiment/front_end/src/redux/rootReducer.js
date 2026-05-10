import { combineReducers } from 'redux';
import configReducer from './config/configReducer';
import instructionReducer from './instruction/instructionReducer';
import playerStatsReducer from './playerStats/playerStatsReducer';
import debugReducer from './debug/debugReducer';

const rootReducer = combineReducers({
    config: configReducer,
    instruction: instructionReducer,
    stats: playerStatsReducer,
    debug: debugReducer,
});

export default rootReducer;