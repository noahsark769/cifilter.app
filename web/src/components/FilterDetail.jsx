import React from 'react';
import styled from 'styled-components';
import FilterTitle from './FilterTitle';
import FilterParameters from './FilterParameters';
import FilterExample from './FilterExample';
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
`;

const TitleContainer = styled.div`
    display: flex;
    flex-direction: row;
    width: 100%;
`;

const FilterDetail = (props) => {
    if (!props.filter) {
        return <Container>Select a CIFilter from the left to get started...</Container>
    }

    return (
        <Container>
            <TitleContainer>
                {props.displaysBack && <a onClick={props.onClickBack} ><IoIosArrowBack size="40" color="#F5BD5D" /></a>}
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