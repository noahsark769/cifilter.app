import React from 'react';
import styled from 'styled-components';
import Nav from '../components/Nav';
import FilterSelect from '../components/FilterSelect';

const OuterWrapper = styled.div`
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    height: 100vh;
`;

const Container = styled.div`
    margin: 48px auto 0 auto;
    flex-grow: 1;
    overflow-y: scroll;
`;

const Main = (props) => {
    console.log(props);
    return (
        <OuterWrapper>
            <Nav />
            <Container>
                <FilterSelect filters={props.pageContext.filters} />
            </Container>
        </OuterWrapper>
    )
};
export default Main;