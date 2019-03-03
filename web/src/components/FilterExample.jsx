import React from 'react';
import styled from 'styled-components';
import FilterExampleImage from './FilterExampleImage';
import FilterDetailSectionHeading from './FilterDetailSectionHeading';
import { IoIosArrowRoundForward } from 'react-icons/io';

const Container = styled.div`

`;

const ImageList = styled.div`
    display: flex;
    flex-direction: row;
`;

const Wrapper = styled.div`
    flex: 4;
    &:first-child {
        margin-right: 20px;
    }
`;

const ArrowContainer = styled.div`
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    margin: 0 20px;
`;

const FilterExample = (props) => {
    console.log(props);
    const outputImageFilename = props.example.data.outputImage.image;
    return (
        <Container>
            <FilterDetailSectionHeading>Example</FilterDetailSectionHeading>
            <ImageList>
                {Object.entries(props.example.data).map((entry) => {
                    const [name, data] = entry;
                    if (name === "_metadata") { return null; }
                    if (data.type !== "image") { return null; }
                    if (name === "outputImage") { return null; }
                    return (
                        <Wrapper>
                            <FilterExampleImage
                                key={name}
                                name={name}
                                filename={`${props.example.basepath}/${data.image}`}
                            />
                        </Wrapper>);
                })}
                <ArrowContainer>
                    <IoIosArrowRoundForward size={50} color="#999" />
                </ArrowContainer>
                <Wrapper>
                    <FilterExampleImage
                        name="outputImage"
                        filename={`${props.example.basepath}/${outputImageFilename}`}
                    />
                </Wrapper>
            </ImageList>
        </Container>
    )
};
export default FilterExample;