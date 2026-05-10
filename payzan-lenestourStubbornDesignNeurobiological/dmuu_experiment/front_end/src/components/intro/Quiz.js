// Quiz component
// Shows questions as cards
import React, { Component, Fragment } from 'react';
import templateParser, {capitalize} from '../../utility/TemplateParser';
import { Card, Button, Row } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { connect } from 'react-redux';
import { setMCQAnswers } from '../../redux/playerStats/playerStatsActions';
const MCQ_TEXT = process.env.PUBLIC_URL + "/assets/instruction_pages/text/mcq.json";

const empty_q = {
    q: '',
    answers: '',
    correct: '',
    ans_info: ''
}

const NUM_QS = 6;

const SPACE_BAR_KEY_CODE = 32;

class Quiz extends Component {

    state = {
        curq: 1,
        reveal: false,
        all_correct: true,
        result: false,
        enable_link: false,
        cur_currect: true,
        q1: empty_q,
        q2: empty_q,
        q3: empty_q,
        q4: empty_q,
        q5: empty_q,
        q6: empty_q,
        assistance: false,
        user_answer: {}
    }

    componentDidMount() {
        fetch(MCQ_TEXT)
        .then( res => res.json())
        .then( res => {
            const {color, probability} = this.props.config.params;

            const {low, high} = probability;
            const low_probability = 100 * low;
            const high_probability = 100 * high;

            const {low_name, high_name} = color;
            const low_color = capitalize(low_name);
            const high_color = capitalize(high_name);

            const prob_config = {low_probability, high_probability, low_color, high_color};

            this.setState({
                q1: res.q1,
                q2: res.q2,
                q3: {
                    ...res.q3,
                    q_extra: {
                        option1: templateParser(res.q3.q_extra.option1, prob_config),
                        option2: templateParser(res.q3.q_extra.option2, prob_config)
                    }
                },
                q4: res.q4,
                q5: res.q5,
                q6: res.q6

            });
        });

        document.addEventListener("keydown", this.key_press, false);
    }

    componentWillUnmount() {
        document.removeEventListener("keydown", this.key_press, false);
    }

    componentDidUpdate() {
        // Hacky way to stop the page from scrolling after update
        if (this.state.went_wrong)
            setTimeout(() => window.scrollTo(0, 0), 200);
    }

    // If the subject has at least one question wrong at the end of the quiz
    // Will not allow them to continue
    // Experimenter can press space once to see all questions and subject's answers
    // Experimenter presses space a second time to show a button to go to id page
    key_press = (e) =>
    {
        // Check for spacebar press
        if (e.keyCode === SPACE_BAR_KEY_CODE)
        {
            // End of quiz and at least one wrong
            const {curq, all_correct} = this.state;
            if (curq === NUM_QS && !all_correct)
            {
                // First space press
                const {went_wrong} = this.state;
                if (!went_wrong)
                {
                    this.setState({...this.state, went_wrong: true});
                }
                else
                {
                    // Second space press
                    this.setState({...this.state, enable_link: true});
                }

            }
        }
    }

    checkAnswer(check)
    {
        let { all_correct, cur_currect } = this.state;
        let {user_answer} = this.state;

        const {curq} = this.state;

        user_answer[`q${curq}`] = check.choice;

        if(!this.state.reveal)
        {
            if (check.choice === check.actual)
            {
                console.log("Correct!");
            }
            else
            {
                console.log("Incorrect!");
                cur_currect = false;
                all_correct = false;
            }
        }

        this.setState({reveal: true, all_correct, cur_currect, user_answer});
    }

    nextQuestion = () =>
    {
        if (this.state.curq < NUM_QS)
        {
            this.setState({curq: this.state.curq + 1, reveal:false, cur_currect: true});
        }
        else
        {
            let { enable_link, assistance, all_correct } = this.state;

            if (all_correct)
                enable_link = true;
            else
                assistance = true;

            this.setState({result: true, assistance, enable_link});
        }
    }

    renderExtraInfo = (extra1, extra2) => 
    {
        return (
            <Fragment>
                <Card>
                    <Card.Header>Option 1</Card.Header>
                    <Card.Body>
                        <Card.Text>
                            {extra1}
                        </Card.Text>
                    </Card.Body>
                </Card>
                <Card className="mt-5">
                    <Card.Header>Option 2</Card.Header>
                    <Card.Body>
                        <Card.Text>
                            {extra2}
                        </Card.Text>
                    </Card.Body>
                </Card>
            </Fragment>
        );
    }

    checkQ = (user, actual) => {
        if (user === actual) {
            return 1;
        }
        return 0;
    }

    submitAnswers = () => {
        const { user_answer, q1, q2, q3, q4, q5, q6 } = this.state;
        const answers = {
           q1: this.checkQ(user_answer.q1, q1.correct), 
           q2: this.checkQ(user_answer.q2, q2.correct), 
           q3: this.checkQ(user_answer.q3, q3.correct), 
           q4: this.checkQ(user_answer.q4, q4.correct), 
           q5: this.checkQ(user_answer.q5, q5.correct), 
           q6: this.checkQ(user_answer.q6, q6.correct), 
        }
        this.props.saveAnswers(answers);
    }

    showGoToIDButton = () =>
    {
        const {enable_link} = this.state;

        if (enable_link)
        {
            this.submitAnswers();
            return (
                <Row className="justify-content-center">
                    <Link to="/id" className="btn btn-primary">Go to ID Page</Link> 
                </Row>
            );
        }

        return null;
    }

    cardHeaderText = () =>
    {
        const {went_wrong, curq, assistance, enable_link} = this.state;


        if (enable_link)
        {
            return "MCQ Finished!";
        }
        else if (went_wrong)
        {
            return "Answers";
        }
        else if (assistance)
        {
            return "Notice";
        }
        else
        {
            return `Q${curq}`;
        }

    }

    cardBodyText = (question) =>
    {
        const {went_wrong, assistance, enable_link} = this.state;

        if (went_wrong || enable_link)
        {
            return "";
        }
        else if (assistance)
        {
            return "Please wait for assistance, thanks very much!";
        }
        else
        {
            return question.q;
        }
    }

    answerCard = (q_num, question) =>
    {
        const {q, answers, correct, q_extra} = question;
        const {user_answer, enable_link} = this.state;

        const correct_answer = answers[correct];
        const user_response = answers[user_answer[`q${q_num}`]];

        let color = 'green';
        if (user_response !== correct_answer)
        {
            color = 'red';
        }

        if (!enable_link)
        {

            return (
                <Card>
                    <Card.Header as="h5">
                        Q{q_num}: {q}
                    </Card.Header>
                    <Card.Body>
                        {q_extra && 
                            (<Fragment>
                                <Card.Text>
                                    Option 1: {q_extra.option1}
                                </Card.Text>
                                <Card.Text>
                                    Option 2: {q_extra.option2}
                                </Card.Text>
                            </Fragment>)}
                        <Card.Text>
                            Wrong answer: {Object.keys(answers).map((key, index) => {
                                if (key !== correct)
                                {
                                    return answers[key];
                                }
                                return '';
                            })}
                        </Card.Text>
                        <Card.Text>
                            Correct answer: {correct_answer}
                        </Card.Text>
                        <Card.Text style={{color}}>
                            <b>You picked: {user_response}</b> 
                        </Card.Text>
                    </Card.Body>
                </Card>
            );
        }

        return null;
    }

    giveAnswer(q)
    {
        if(q.correct === "c1")
        {
            return q.answers.c1;
        }
        return q.answers.c2;
    }


    revealInfo = (question) =>
    {
        if (this.state.reveal)
        {
            return (<em style={{color:"blue"}}>Answer: {this.giveAnswer(question)}<br/>{question.ans_info}</em>);
        }
    }

    getButtonStyle = (question) =>
    {
        let option1_class = "mr-5";
        let option2_class = "ml-5";

        if(this.state.reveal)
        {
            if (question.correct === "c1")
            {
                option1_class += " btn-success";
                option2_class += " disabled";
                if (!this.state.cur_currect)
                {
                    option2_class += " btn-danger";
                }
            }
            else
            {
                option1_class += " disabled";
                option2_class += " btn-success";
                if (!this.state.cur_currect)
                {
                    option1_class += ' btn-danger';
                }
            }
        }

        return {option1_class, option2_class};
    }

    showInfo = (question) =>
    {
        const {went_wrong, enable_link} = this.state;
        if (enable_link)
        {
            return null;
        }
        else if (went_wrong)
        {
            return (
                <Fragment>
                    {this.answerCard(1, this.state.q1)}
                    {this.answerCard(2, this.state.q2)}
                    {this.answerCard(3, this.state.q3)}
                    {this.answerCard(4, this.state.q4)}
                    {this.answerCard(5, this.state.q5)}
                    {this.answerCard(6, this.state.q6)}
                </Fragment>
            );
        }   
        else if(!this.state.assistance)
        {
            const {option1_class, option2_class} = this.getButtonStyle(question);
            return (
                <Fragment>
                    {question.q_extra && this.renderExtraInfo(question.q_extra.option1, question.q_extra.option2)}
                    {this.revealInfo(question)}
                    <Row className="justify-content-center mt-5">
                        <Button onClick={() => this.checkAnswer({choice: 'c1', actual: question.correct})} className={option1_class}>{question.answers.c1}</Button>
                        <Button onClick={() => this.checkAnswer({choice: 'c2', actual: question.correct})} className={option2_class}>{question.answers.c2}</Button>
                    </Row>
                    
                    <Row className="justify-content-center mt-5">
                        {this.state.reveal && this.state.curq < NUM_QS && (
                                <Button onClick={this.nextQuestion}>{"Next Question"}</Button>
                        )}
                        {this.state.reveal && this.state.curq === NUM_QS && (
                            <Button onClick={this.nextQuestion}>Next</Button>
                        )}
                    </Row>
                </Fragment>);
        }

        return null;
    }

    render() {

        let question;
        switch(this.state.curq)
        {
            case 1:
                question = this.state.q1;
                break;

            case 2:
                question = this.state.q2;
                break;

            case 3:
                question = this.state.q3;
                break;

            case 4:
                question = this.state.q4;
                break;

            case 5:
                question = this.state.q5;
                break;

            case 6:
                question = this.state.q6;
                break;

            default:
                question = this.state.q1;
                break;
        }


        return (
            <div>
                <Card>
                    <Card.Header as="h5" className="text-center">{this.cardHeaderText()}</Card.Header>
                    <Card.Body>
                        <Card.Text>
                            {this.cardBodyText(question)}
                        </Card.Text>
                        {this.showInfo(question)}
                        {this.showGoToIDButton()}
                    </Card.Body>
                </Card>
            </div>
        )
    }
}

const mapDispatchToProps = (dispatch) => {
    return {
        saveAnswers: (answers) => dispatch(setMCQAnswers(answers))
    }
}

export default connect(null, mapDispatchToProps)(Quiz);