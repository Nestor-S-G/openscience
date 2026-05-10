// The ordering of the instructions and any special parameters
import InsParticipate from './pages/InsParticipate';
import InsWelcome from './pages/InsWelcome'; 
import InsRules from './pages/InsRules';
import InsPleaseNote from './pages/InsPleaseNote';
import InsSimulation from './pages/InsSimulation';
import InsCheeky from './pages/InsCheeky';
import InsExpect from './pages/InsExpect';
import InsPractice from './pages/InsPractice';
import InsMCQ from './pages/InsMCQ';
import InsFAQ from './pages/InsFAQ';
import { Redirect } from 'react-router-dom';

// Names
export const INS_PARTICIPATE = "ins_participate";
export const INS_WELCOME = "ins_welcome";
export const INS_RULES = "ins_rules";
export const INS_PLEASE_NOTE = "ins_please_note";
export const INS_SIMULATION = "ins_simulation";
export const INS_CHEEKY = "ins_cheeky";
export const INS_EXPECT = "ins_expect";
export const INS_PRACTICE = "ins_practice";
export const INS_MCQ = "ins_mcq";
export const INS_FAQ = "ins_faq";
export const GAME = "game";

export const FIRST_PAGE = INS_PARTICIPATE;

export const NEXT_PAGE = "next_page";
export const PREV_PAGE = "prev_page";

// Action must be next page or prev page
export const switchPage = (curPage, action) =>
{
    switch(curPage) {
        case INS_PARTICIPATE:
            if (action === NEXT_PAGE)
                return INS_WELCOME
            break;

        case INS_WELCOME:
            if (action === NEXT_PAGE)
                return INS_RULES;
            if (action === PREV_PAGE)
                return INS_PARTICIPATE;
            break;

        case INS_RULES:
            if (action === PREV_PAGE)
                return INS_WELCOME;
            if (action === NEXT_PAGE)
                return INS_PLEASE_NOTE;
            break;

        case INS_PLEASE_NOTE:
            if (action === PREV_PAGE)
                return INS_RULES;
            if (action === NEXT_PAGE)
                return INS_SIMULATION;
            break;

        case INS_SIMULATION:
            if (action === PREV_PAGE)
                return INS_PLEASE_NOTE;
            if (action === NEXT_PAGE)
                return INS_CHEEKY;
            break;

        case INS_CHEEKY:
            if (action === PREV_PAGE)
                return INS_SIMULATION;
            if (action === NEXT_PAGE)
                return INS_EXPECT;
            break;

        case INS_EXPECT:
            if (action === PREV_PAGE)
                return INS_CHEEKY;
            if (action === NEXT_PAGE)
                return INS_PRACTICE;
            break;

        case INS_PRACTICE:
            if (action === PREV_PAGE)
                return INS_EXPECT;
            if (action === NEXT_PAGE)
                return INS_FAQ;
            break;

        case INS_FAQ:
            if (action === PREV_PAGE)
                return INS_PRACTICE;
            if (action === NEXT_PAGE)
                return INS_MCQ;
            break;

        case INS_MCQ:
            if (action === PREV_PAGE)
                return INS_FAQ;
            if (action === NEXT_PAGE)
                return GAME;
            break;

        default:
            return curPage;
    }
}

export const getPage = (curPage) => {
    switch(curPage) {
        case INS_PARTICIPATE:
            return InsParticipate;

        case INS_WELCOME:
            return InsWelcome;

        case INS_RULES:
            return InsRules;

        case INS_PLEASE_NOTE:
            return InsPleaseNote;

        case INS_SIMULATION:
            return InsSimulation;

        case INS_CHEEKY:
            return InsCheeky;

        case INS_EXPECT:
            return InsExpect;

        case INS_PRACTICE:
            return InsPractice;

        case INS_MCQ:
            return InsMCQ;

        case INS_FAQ:
            return InsFAQ;

        case GAME:
            return Redirect;

        default:
            return null;
    }
}

export const BUTTON_SHOW_BOTH = "button_show_both";
export const BUTTON_SHOW_PREV_ONLY = "button_show_prev_only";
export const BUTTON_SHOW_NEXT_ONLY = "button_show_next_only";
export const BUTTON_SHOW_NONE = "button_show_none";

export const instructionButtonShow = (page, instructionState) =>
{
    switch(page)
    {
        case INS_PARTICIPATE:
            return BUTTON_SHOW_NEXT_ONLY;

        case INS_WELCOME:
            return BUTTON_SHOW_BOTH;
        
        case INS_RULES:
            return BUTTON_SHOW_BOTH;

        case INS_PLEASE_NOTE:
            return BUTTON_SHOW_BOTH;

        case INS_SIMULATION:
            if (instructionState.simulationComplete)
            {
                return BUTTON_SHOW_BOTH;
            }
            return BUTTON_SHOW_PREV_ONLY;

        case INS_CHEEKY:
            return BUTTON_SHOW_BOTH;

        case INS_EXPECT:
            return BUTTON_SHOW_BOTH

        case INS_PRACTICE:
            if (instructionState.practiceComplete)
            {
                return BUTTON_SHOW_BOTH;
            }
            return BUTTON_SHOW_PREV_ONLY;

        case INS_FAQ:
            return BUTTON_SHOW_BOTH;

        case INS_MCQ:
            return BUTTON_SHOW_PREV_ONLY;

        default:
            return BUTTON_SHOW_NONE;
    }

} 