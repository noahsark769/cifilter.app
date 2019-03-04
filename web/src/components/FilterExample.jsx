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
    const outputImageData = props.example.data.parameterValues.filter(
        ({ name }) => name === 'outputImage'
    )[0];
    const outputImageFilename = outputImageData.additionalData.image;

    const renderWasCropped = () => {
        if (outputImageData.wasCropped) {
            return (<span>Note: this example image was cropped since the original outputImage had infinite extent.</span>)
        }
        return null;
    };

    return (
        <Container>
            <FilterDetailSectionHeading>Example</FilterDetailSectionHeading>
            <ImageList>
                {props.example.data.parameterValues.map((value) => {
                    const {name, type, additionalData} = value;
                    if (type !== "image") { return null; }
                    if (name === "outputImage") { return null; }
                    return (
                        <Wrapper>
                            <FilterExampleImage
                                key={name}
                                name={name}
                                filename={`${props.example.basepath}/${additionalData.image}`}
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
                    {renderWasCropped()}
                </Wrapper>
            </ImageList>
        </Container>
    )
};
export default FilterExample;