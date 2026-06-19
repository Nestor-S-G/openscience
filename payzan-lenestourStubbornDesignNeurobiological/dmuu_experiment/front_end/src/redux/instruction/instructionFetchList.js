// A list of all instructions to fetch
import axios from "axios"

const INSTRUCTION_DIR = process.env.PUBLIC_URL + "/assets/instruction_pages/text/";

export const instruction_list = [
    "participate.json",
    "welcome.json",
    "rules.json",
    "please_note.json",
    "simulation.json",
    "cheeky.json",
    "expect.json",
    "practice.json",
    "mcq_text.json",
    "mcq.json"
]

export const instruction_fetch_list = instruction_list.map((val) => axios.get(INSTRUCTION_DIR + val));