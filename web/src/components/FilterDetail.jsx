import React from 'react';
import styled from 'styled-components';
import FilterTitle from './FilterTitle';
import FilterParameters from './FilterParameters';

const Container = styled.div`
    width: 700px;
    height: 100%;
    overflow-y: scroll;
    padding-bottom: 48px;
`;

const Description = styled.div`
    font-size: 16px;
    line-height: 22px;
`;

const FilterDetail = (props) => {
    if (!props.filter) {
        return <Container>Ain't nothin here</Container>
    }
    return (
        <Container>
            <FilterTitle
                name={props.filter.name}
                categories={props.filter.categories}
                availableMac={props.filter.availableMac}
                availableIOS={props.filter.availableIOS}
                className="margin-bottom--md" />
            <Description>{props.filter.description}</Description>
            <FilterParameters parameters={props.filter.parameters} />
        </Container>
    )
};
export default FilterDetail;