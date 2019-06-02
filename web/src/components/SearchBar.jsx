import React from 'react';
import styled from 'styled-components';
import { IoIosSearch, IoIosCloseCircleOutline } from 'react-icons/io';

const Container = styled.div`
    border: 1px solid #cccccc;
    border-radius: 3px;
    background-color: white;
    padding: 10px;

    @media (prefers-color-scheme: dark) {
        background-color: #eee;

        textarea {
            background-color: #eee;
        }
    }

    display: flex;
    flex-direction: row;
    align-items: center;
`;

const Input = styled.textarea`
    margin: 0;
    padding: 0;
    -webkit-appearance: none;
    appearance: none;
    border: none;

    font-size: 14px;
    line-height: 16px;
    height: 16px;
    color: #666666;
    resize: none;

    &:focus {
        outline: none;
    }
    flex: 1
`;

const CloseButtonWraper = styled.div`
    color: #ccc;
    cursor: pointer;
    display: flex;
`;

class SearchBar extends React.Component {
    state = { text: "" }

    constructor(props) {
        super(props);
        this.input = React.createRef();
    }

    handleChange(event) {
        let newText = event.target.value;
        this.setState({ text: newText});
        this.props.onChange(newText);
    }

    handleClear() {
        this.input.current.value = "";
        this.setState({ text: "" })
        this.props.onChange("");
        this.input.current.focus();
    }

    render() {
        return (
            <Container>
                <IoIosSearch size="16" className="margin-right--sm"/>
                <Input ref={this.input} onChange={this.handleChange.bind(this)} value={this.props.initialText} />
                {this.state.text.length > 0 &&
                    <CloseButtonWraper>
                        <IoIosCloseCircleOutline
                            size="16"
                            style={{color: "#ccc"}}
                            onClick={this.handleClear.bind(this)}
                            placeholder="HEyyy" />
                    </CloseButtonWraper>
                }
            </Container>
        );
    }
};
export default SearchBar;