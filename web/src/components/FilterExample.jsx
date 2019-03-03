import React from 'react';
import styled from 'styled-components';
import FilterExampleImage from './FilterExampleImage';
import FilterDetailSectionHeading from './FilterDetailSectionHeading';
import { IoIosArrowRoundDown } from 'react-icons/io';

const Container = styled.div`

`;

const ImageList = styled.div`
    display: flex;
    flex-direction: row;
`;

const Wrapper = styled.div`
    flex: 1;
    &:first-child {
        margin-right: 20px;
    }
`;

const ArrowContainer = styled.div`
    display: flex;
    justify-content: center;
    margin: 20px 0;
`;

const FilterExample = (props) => {
    console.log(props);

    return (
        <Container>
            <FilterDetailSectionHeading>Example</FilterDetailSectionHeading>
            <ImageList>
                {Object.entries(props.example.data._metadata._associations).map((entry) => {
                    const [name, data] = entry;
                    return (
                        <Wrapper>
                            <FilterExampleImage
                                key={name}
                                name={name}
                                filename={`${props.example.basepath}/${data.image}`}
                            />
                        </Wrapper>);
                })}
            </ImageList>
            <ArrowContainer><IoIosArrowRoundDown size={50} color="#999" /></ArrowContainer>
        </Container>
    )
};
export default FilterExample;