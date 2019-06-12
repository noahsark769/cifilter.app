import React from 'react';
import styled from 'styled-components';
import FilterTitle from './FilterTitle';
import FilterParameters from './FilterParameters';
import FilterExample from './FilterExample';
import EmptyFilterDetail from './EmptyFilterDetail';
import { IoIosArrowBack } from "react-icons/io";

const Container = styled.div`
    width: 700px;
    height: 100%;
    overflow-y: scroll;
    padding-bottom: 48px;
    padding-right: 12px;
`;

const Description = styled.div`
    font-size: 16px;
    line-height: 22px;

    @media (prefers-color-scheme: dark) {
        color: #fff;
    }
`;

const TitleContainer = styled.div`
    display: flex;
    flex-direction: row;
    width: 100%;
`;

const Button = styled.button`
    &, &:active, &:focus {
        margin: 0;
        padding: 0;
        -webkit-appearance: none;
        appearance: none;
        border: none;
        background: none;
        outline: 0;

        display: inline-flex;
        align-items: flex-start;
        flex-direction: column;
    }
`;

const FilterDetail = (props) => {
    if (!props.filter) {
        return <Container>
            <EmptyFilterDetail />
        </Container>
    }

    return (
        <Container>
            <TitleContainer>
                {props.displaysBack && <Button onClick={props.onClickBack} ><IoIosArrowBack size="40" color="#F5BD5D" /></Button>}
                <FilterTitle
                    style={{flex: "1"}}
                    name={props.filter.name}
                    categories={props.filter.categories}
                    availableMac={props.filter.availableMac}
                    availableIOS={props.filter.availableIOS}
                    className="margin-bottom--md" />
            </TitleContainer>
            <Description>{props.filter.description}</Description>
            <FilterParameters parameters={props.filter.parameters} />
            { props.filter.examples && <FilterExample example={props.filter.examples[0]} /> }
        </Container>
    )
};
export default FilterDetail;