class State {
    constructor() {
        this.parent = null;
    }

    onUpdate() {}

    getName() { return "none"; }

    onEnter() {}

    onExit() {}
}

class StateMachine {
    constructor() {
        this.current_state = null;
        this.states = {}
    }

    addState(state) {
        state.parent = this;
        this.states[state.getName()] = state;
    }

    changeState(state_name) {
        if (this.current_state !== null) {
            this.current_state.onExit();
        }

        this.current_state = this.states[state_name];

        this.current_state.onEnter();
    }

    update() {
        if (this.current_state === null) {
            return;
        }

        this.current_state.onUpdate();
    }
}

module.exports = {
    State,
    StateMachine
}